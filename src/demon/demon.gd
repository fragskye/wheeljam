class_name Demon extends Node3D

@onready var demon_face_visual: DemonFaceVisual = %DemonFaceVisual
@onready var demon_pcam: PhantomCamera3D = %DemonPhantomCamera

@export var data: DemonData = null
@export var debug_face: bool = false
@export var debug_face_opinion: int = 0

var _previewed_index: int = 0
var _verdict: DemonVerdict = null

var health: float = 0.0

func _ready() -> void:
	data.ready()
	health = data.max_health * 0.5
	_on_battle_player_action_previewed(_previewed_index)
	SignalBus.battle_begin.connect(_on_battle_begin)
	SignalBus.battle_end.connect(_on_battle_end)
	SignalBus.battle_player_action_previewed.connect(_on_battle_player_action_previewed)
	SignalBus.battle_player_action_selected.connect(_on_battle_player_action_selected)
	demon_face_visual.data = data

func _process(delta: float) -> void:
	if debug_face:
		_verdict = DemonVerdict.new()
		_verdict.multiplier = 1.0
		_verdict.opinion = debug_face_opinion
		demon_face_visual.set_face(_get_face())
	
	if health > 0 && health < data.max_health:
		var in_battle: bool = InputManager.get_input_state() == InputManager.InputState.BATTLE
		var drain: float = -(data.health_drain if in_battle else data.health_drain_outside_battle) * delta
		health = clampf(health + drain, 0.0, data.max_health)
		SignalBus.battle_demon_health_changed.emit(health / data.max_health, health, drain, false)
		if health <= 0:
			SignalBus.battle_lost.emit()

func _on_battle_begin() -> void:
	demon_pcam.priority = 2
	_on_battle_player_action_previewed(_previewed_index)

func _on_battle_end() -> void:
	demon_pcam.priority = 0

func _on_battle_player_action_previewed(index: int) -> void:
	_previewed_index = index
	_verdict = data.evaluate(index)
	demon_face_visual.set_face(_get_face())

func _on_battle_player_action_selected(index: int, multiplier: float) -> void:
	# TODO: Call data.next_phase() when health passes midway point, play cinematic
	_verdict = data.evaluate(index)
	var result: float = _verdict.multiplier * multiplier
	SignalBus.battle_demon_verdict.emit(multiplier, _verdict.multiplier, result)
	health = clampf(health + result, 0.0, data.max_health)
	SignalBus.battle_demon_health_changed.emit(health / data.max_health, health, result, true)
	if health <= 0:
		SignalBus.battle_lost.emit()
	if health >= data.max_health:
		SignalBus.battle_won.emit()
	print("index", index)
	print("verdict mult", _verdict.multiplier)
	print("mult", multiplier)
	print(result)

func _get_face() -> DemonFace:
	var faces_size: int = data.faces.size()
	if faces_size == 1:
		return data.faces[0]
	var opinion_index: float = float(_verdict.opinion) / float(DemonVerdict.MAX_OPINION) * (faces_size - 1)
	var lower_index: int = floor(opinion_index)
	var upper_index: int = ceil(opinion_index)
	if lower_index == upper_index:
		return data.faces[lower_index]
	else:
		return data.faces[lower_index].lerp(data.faces[upper_index], opinion_index - floorf(opinion_index))
