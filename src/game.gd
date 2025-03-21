class_name Game extends Node3D

const DEMON: PackedScene = preload("res://prefabs/demon.tscn")
const BATTLE_LAYER: PackedScene = preload("res://prefabs/ui/battle_layer.tscn")

const LOSE_SCREEN: PackedScene = preload("res://prefabs/ui/lose_screen.tscn")
const WIN_SCREEN: PackedScene = preload("res://prefabs/ui/win_screen.tscn")

@onready var battle_layer: BattleLayer = %BattleLayer
@onready var spawn_demon_area: Area3D = %SpawnDemonArea
@onready var intro_animation_player: AnimationPlayer = %IntroAnimationPlayer
@onready var cutscene_fade: ColorRect = %CutsceneFade

@export var demons: Array[DemonData] = []
@export var demon_index: int = 0
@export var time_between_demons: float = 0.0 ## Starts counting after the player leaves the street

var demon: Demon = null

var _can_spawn_demon: bool = true
var _in_spawn_demon_area: bool = false

func _ready() -> void:
	SignalBus.battle_won.connect(_on_battle_won)
	SignalBus.battle_lost.connect(_on_battle_lost)
	Global.game = self
	InputManager.push_input_state(InputManager.InputState.CUTSCENE)
	intro_animation_player.play("intro")
	await intro_animation_player.animation_finished
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cutscene_fade, "color", Color(0.0, 0.0, 0.0, 0.0), 1.0)
	InputManager.pop_input_state()

func _process(_delta: float) -> void:
	if _can_spawn_demon && _in_spawn_demon_area:
		spawn_next_demon()

func spawn_next_demon() -> void:
	if demon_index >= demons.size():
		return
	
	_can_spawn_demon = false
	
	# SHHHHHHHHHHHHHHHHHH i don't want to think how to reset the wheel properly right now, it has a lot of state in it
	battle_layer.queue_free()
	battle_layer = BATTLE_LAYER.instantiate()
	add_child(battle_layer)
	
	# phantom camera's built-in noise seems to be broken in 4.4 :( it causes severe flickering
	#demon_spawn_noise_emitter.emit()
	Global.player.camera_shake.shake(1.0, 3.75)
	demon = DEMON.instantiate()
	demon.data = demons[demon_index]
	add_child(demon)
	await get_tree().create_timer(3.0).timeout
	NotificationLayer.show_toast("What was that?")

func _on_battle_won() -> void:
	await battle_layer.demon_verdict_anim_finished
	InputManager.pop_input_state()
	demon.queue_free()
	demon_index += 1
	if demon_index < demons.size():
		NotificationLayer.show_toast("More demons will be back soon. I need to prepare.")
	else:
		Global.game_complete = true
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(cutscene_fade, "color", Color(0.0, 0.0, 0.0, 1.0), 2.0)
		await get_tree().create_timer(2.5).timeout
		InputManager.switch_input_state(InputManager.InputState.MENU)
		get_tree().change_scene_to_packed(WIN_SCREEN)
		return
	await spawn_demon_area.body_exited
	await get_tree().create_timer(time_between_demons).timeout
	_can_spawn_demon = true

func _on_battle_lost() -> void:
	Global.game_complete = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(cutscene_fade, "color", Color(0.0, 0.0, 0.0, 1.0), 2.0)
	await get_tree().create_timer(2.5).timeout
	InputManager.switch_input_state(InputManager.InputState.MENU)
	get_tree().change_scene_to_packed(LOSE_SCREEN)

func _on_spawn_demon_area_body_entered(_body: Node3D) -> void:
	_in_spawn_demon_area = true

func _on_spawn_demon_area_body_exited(_body: Node3D) -> void:
	_in_spawn_demon_area = false
