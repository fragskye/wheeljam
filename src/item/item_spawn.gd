class_name ItemSpawn extends Node3D

@export var pool: int = 0
@export var floating: bool = false ## Floating item spawns will spawn a page, always. Intended to be used on walls
@export var random_angle: float = 0.0
@export var random_position: Vector3 = Vector3.ZERO
