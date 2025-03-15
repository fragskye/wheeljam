class_name Demon extends Node3D

@onready var demon_face_visual: DemonFaceVisual = %DemonFaceVisual

@export var data: DemonData = null

var _previewed_index: int = 0
var _verdict: DemonVerdict = null

func _ready() -> void:
	_on_battle_player_action_previewed(_previewed_index)
	SignalBus.battle_begin.connect(_on_battle_begin)
	SignalBus.battle_player_action_previewed.connect(_on_battle_player_action_previewed)
	SignalBus.battle_player_action_selected.connect(_on_battle_player_action_selected)
	demon_face_visual.data = data

func _on_battle_begin() -> void:
	_on_battle_player_action_previewed(_previewed_index)

func _on_battle_player_action_previewed(index: int) -> void:
	_previewed_index = index
	_verdict = data.evaluate(index)
	demon_face_visual.set_face(_get_face())

func _on_battle_player_action_selected(_index: int) -> void:
	pass

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
