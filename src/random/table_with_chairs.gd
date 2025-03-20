@tool class_name TableWithChairs extends Node3D

@onready var chair: Node3D = %Chair
@onready var chair_2: Node3D = %Chair2
@onready var chair_3: Node3D = %Chair3
@onready var chair_4: Node3D = %Chair4

@export var random_seed: int = 0

@export_tool_button("Randomize Seed") var randomize_seed_action: Callable = randomize_seed
@export_tool_button("Sync to Randomness") var randomize_chairs_action: Callable = randomize_chairs

@export var position_variance: float = 0.1
@export var rotation_variance: float = 5.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	randomize_chairs()

func randomize_seed() -> void:
	random_seed = randi()
	randomize_chairs()

func randomize_chairs() -> void:
	var backup_random_seed: int = randi()
	seed(random_seed)
	chair.position = Vector3(-0.45 + randf_range(-position_variance, position_variance), 0.0, -0.9 + randf_range(-position_variance, position_variance))
	chair_2.position = Vector3(0.45 + randf_range(-position_variance, position_variance), 0.0, -0.9 + randf_range(-position_variance, position_variance))
	chair_3.position = Vector3(0.45 + randf_range(-position_variance, position_variance), 0.0, 0.9 + randf_range(-position_variance, position_variance))
	chair_4.position = Vector3(-0.45 + randf_range(-position_variance, position_variance), 0.0, 0.9 + randf_range(-position_variance, position_variance))
	chair.rotation_degrees = Vector3(0.0, 0.0 + randf_range(-rotation_variance, rotation_variance), 0.0)
	chair_2.rotation_degrees = Vector3(0.0, 0.0 + randf_range(-rotation_variance, rotation_variance), 0.0)
	chair_3.rotation_degrees = Vector3(0.0, 180.0 + randf_range(-rotation_variance, rotation_variance), 0.0)
	chair_4.rotation_degrees = Vector3(0.0, 180.0 + randf_range(-rotation_variance, rotation_variance), 0.0)
	seed(backup_random_seed)
