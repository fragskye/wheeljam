class_name EnemySpawn extends Area3D

const ENEMY: PackedScene = preload("res://prefabs/enemy.tscn")

@export var cooldown: float = 0.0

var delay: float = 0.0

var player_entered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if delay > 0.0:
		delay = maxf(0.0, delay - delta)
	
	if player_entered:
		if delay <= 0.0:
			delay = cooldown
			add_child(ENEMY.instantiate())

func _on_body_entered(_body: Node3D) -> void:
	player_entered = true

func _on_body_exited(_body: Node3D) -> void:
	player_entered = false
