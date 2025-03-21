class_name Demon extends Node3D

@onready var demon_face_visual: DemonFaceVisual = %DemonFaceVisual
@onready var demon_pcam: PhantomCamera3D = %DemonPhantomCamera
@onready var next_phase_pcam: PhantomCamera3D = %NextPhasePhantomCamera

@export var data: DemonData = null
@export var debug_face: bool = false
@export var debug_face_opinion: int = 0

var _previewed_index: int = 0
var _verdict: DemonVerdict = null

var health: float = 0.0

var _in_next_phase: bool = false
var _next_phase_health: float = 0.0
var _next_phase_cutscene: bool = false

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
	
	if !_next_phase_cutscene && health > 0 && health < data.max_health:
		var in_battle: bool = InputManager.get_input_state() == InputManager.InputState.BATTLE
		var drain: float = -(data.health_drain if in_battle else data.health_drain_outside_battle) * delta
		health = clampf(health + drain, 0.0, data.max_health)
		SignalBus.battle_demon_health_changed.emit(health / data.max_health, health, drain, false)
		if health <= 0:
			SignalBus.battle_lost.emit()

func _on_battle_begin() -> void:
	_next_phase_health = health * 0.5 + data.max_health * 0.5
	demon_pcam.priority = 2
	_on_battle_player_action_previewed(_previewed_index)

func _on_battle_end() -> void:
	demon_pcam.priority = 0

func _on_battle_player_action_previewed(index: int) -> void:
	_previewed_index = index
	_verdict = data.evaluate(index)
	demon_face_visual.set_face(_get_face())

func _on_battle_player_action_selected(index: int, multiplier: float) -> void:
	_verdict = data.evaluate(index)
	if !Global.battle_layer._tutorial_bad_seen && _verdict.multiplier <= 0.0:
		Global.battle_layer._tutorial_bad_seen = true
		NotificationLayer.show_toast("The demon didn't like that action...")
	if !Global.battle_layer._tutorial_good_seen && _verdict.multiplier > 0.0:
		Global.battle_layer._tutorial_good_seen = true
		NotificationLayer.show_toast("The demon liked that action!")
	var result: float = _verdict.multiplier * multiplier
	SignalBus.battle_demon_verdict.emit(multiplier, _verdict.multiplier, result)
	health = clampf(health + result, 0.0, data.max_health)
	SignalBus.battle_demon_health_changed.emit(health / data.max_health, health, result, true)
	var next_phase: bool = false
	if health <= 0:
		SignalBus.battle_lost.emit()
	elif health >= data.max_health:
		SignalBus.battle_won.emit()
	elif !_in_next_phase && health >= _next_phase_health:
		next_phase = true
	print("index", index)
	print("verdict mult", _verdict.multiplier)
	print("mult", multiplier)
	print(result)
	await get_tree().process_frame
	if next_phase:
		start_next_phase()

func _get_face() -> DemonFace:
	var faces_size: int = data.faces.size()
	if faces_size == 1:
		return data.faces[0]
	var opinion_index: float = float(_verdict.opinion) / float(data.max_verdict_opinion) * (faces_size - 1)
	var lower_index: int = floor(opinion_index)
	var upper_index: int = ceil(opinion_index)
	if lower_index == upper_index:
		return data.faces[lower_index]
	else:
		return data.faces[lower_index].lerp(data.faces[upper_index], opinion_index - floorf(opinion_index))

func start_next_phase() -> void:
	_in_next_phase = true
	if !data.next_phase():
		return
	_next_phase_cutscene = true
	InputManager.push_input_state(InputManager.InputState.BATTLE_NEXT_PHASE)
	next_phase_pcam.priority = 2
	await get_tree().create_timer(2.5).timeout
	NotificationLayer.show_toast("Something feels different...")
	await get_tree().create_timer(5.0).timeout
	var old_duration: float = demon_pcam.tween_resource.duration
	demon_pcam.tween_resource.duration = 2.0
	next_phase_pcam.priority = 0
	await get_tree().create_timer(2.1).timeout
	demon_pcam.tween_resource.duration = old_duration
	InputManager.pop_input_state()
	_next_phase_cutscene = false
