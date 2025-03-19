class_name RandomMesh extends Node3D

@export var mesh: MeshInstance3D = null

@export var override_range_index: int = -1

@export var width: float = 0.0

@export var hue_ranges: Array[Vector2] = []
@export var saturation_ranges: Array[Vector2] = []
@export var value_ranges: Array[Vector2] = []

@export var min_scale: float = 1.0
@export var max_scale: float = 1.0

func _ready() -> void:
	var range_index: int = randi_range(0, hue_ranges.size() - 1)
	if override_range_index >= 0:
		range_index = override_range_index
	var hue_range: Vector2 = hue_ranges[range_index]
	var saturation_range: Vector2 = saturation_ranges[range_index]
	var value_range: Vector2 = value_ranges[range_index]
	mesh.set_instance_shader_parameter("hue_shift", randf_range(hue_range.x, hue_range.y))
	mesh.set_instance_shader_parameter("saturation_scalar", randf_range(saturation_range.x, saturation_range.y))
	mesh.set_instance_shader_parameter("value_scalar", randf_range(value_range.x, value_range.y))
	mesh.scale = randf_range(min_scale, max_scale) * Vector3.ONE

func get_ranges_count() -> int:
	return hue_ranges.size()
