class_name Game extends Node3D

const DEMON: PackedScene = preload("res://prefabs/demon.tscn")
const BATTLE_LAYER: PackedScene = preload("res://prefabs/ui/battle_layer.tscn")

@onready var battle_layer: BattleLayer = %BattleLayer

@export var demons: Array[DemonData] = []
@export var demon_index: int = 0
@export var time_between_demons: float = 0.0

var demon: Demon = null

func _ready() -> void:
	SignalBus.battle_won.connect(_on_battle_won)
	SignalBus.battle_lost.connect(_on_battle_lost)
	await get_tree().create_timer(2.0).timeout
	spawn_next_demon()

func spawn_next_demon() -> void:
	# SHHHHHHHHHHHHHHHHHH i don't want to think how to reset the wheel properly right now, it has a lot of state in it
	battle_layer.queue_free()
	battle_layer = BATTLE_LAYER.instantiate()
	add_child(battle_layer)
	
	# phantom camera's built-in noise seems to be broken in 4.4 :( it causes severe flickering
	#demon_spawn_noise_emitter.emit()
	Global.player.camera_shake.shake(1.0, 3.0)
	demon = DEMON.instantiate()
	demon.data = demons[demon_index]
	add_child(demon)
	await get_tree().create_timer(2.0).timeout
	NotificationLayer.show_toast("What was that?")

func _on_battle_won() -> void:
	demon.queue_free()
	demon_index += 1
	if demon_index < demons.size():
		NotificationLayer.show_toast("More demons will be back soon. I need to prepare.")
	get_tree().create_timer(time_between_demons).timeout.connect(spawn_next_demon)

func _on_battle_lost() -> void:
	pass
