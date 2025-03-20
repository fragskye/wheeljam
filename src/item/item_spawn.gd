class_name ItemSpawn extends Node3D

@export var pool: int = 0
@export var mandatory_page: bool = false ## Item spawn will spawn a page, always.
@export var floating: bool = false ## Floating item spawn intended to be used on walls. Also acts as a mandatory page
@export var random_angle: float = 0.0
@export var random_position: Vector3 = Vector3.ZERO
