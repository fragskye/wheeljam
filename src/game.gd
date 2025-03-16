class_name Game extends Node3D

const DEMON: PackedScene = preload("res://prefabs/demon.tscn")

@export var demons: Array[DemonData] = []
@export var demon_index: int = 0

var demon: Demon = null

func _ready() -> void:
	SignalBus.battle_won.connect(_on_battle_won)
	SignalBus.battle_lost.connect(_on_battle_lost)
	spawn_next_demon()

func spawn_next_demon() -> void:
	demon = DEMON.instantiate()
	demon.data = demons[demon_index]
	add_child(demon)

func _on_battle_won() -> void:
	demon.queue_free()

func _on_battle_lost() -> void:
	pass
