class_name EnemySpawn extends Area3D

const ENEMY: PackedScene = preload("res://prefabs/enemy.tscn")

@export var cooldown: float = 0.0

var delay: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if delay > 0.0:
		delay = maxf(0.0, delay - delta)

func _on_body_entered(_body: Node3D) -> void:
	if delay <= 0.0:
		delay = cooldown
		add_child(ENEMY.instantiate())
