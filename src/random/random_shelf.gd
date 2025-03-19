class_name RandomShelf extends Node3D

@export var meshes: Array[PackedScene] = []

@export var heights: Array[float] = []
@export var width: float = 0.0
@export var depth: float = 0.0

@export var set_minimum: int = 0
@export var set_maxmimum: int = 0
@export var mesh_spacing_variance: float = 0.0
@export var gap_spacing: float = 0.0
@export var gap_spacing_variance: float = 0.0

func _ready() -> void:
	var min_x: float = -width * 0.5
	var max_x: float = width * 0.5
	for height: float in heights:
		var x: float = min_x + randf_range(0.0, mesh_spacing_variance)
		var set_count: int = randi_range(set_minimum, set_maxmimum)
		var prefab: PackedScene = meshes.pick_random()
		var override_range_index: int = -1
		var mesh_width: float = 0.0
		while x <= max_x - mesh_width:
			var mesh: RandomMesh = prefab.instantiate()
			if override_range_index == -1:
				override_range_index = randi_range(0, mesh.get_ranges_count() - 1)
			mesh.override_range_index = override_range_index
			add_child(mesh)
			mesh.position = Vector3(x, height, depth)
			mesh_width = mesh.width
			x += mesh_width
			set_count -= 1
			if set_count <= 0:
				set_count = randi_range(set_minimum, set_maxmimum)
				prefab = meshes.pick_random()
				override_range_index = -1
				x += gap_spacing + randf_range(0.0, gap_spacing_variance)
			else:
				x += randf_range(0.0, mesh_spacing_variance)
