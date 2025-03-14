class_name InteractionSystem extends Node3D

@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var pcam: PhantomCamera3D = %PhantomCamera3D

@export var reach_distance: float = 1.0
@export_flags_3d_physics var blocker_mask: int = 0xFFFFFFFF
@export_flags_3d_physics var interactable_mask: int = 0xFFFFFFFF
@export var sphere_shape: SphereShape3D = null

@export var debug: bool = false

var hovering: CollisionObject3D = null

func _process(delta: float) -> void:
	_update_hovering()
	
	if InputManager.get_input_state() != InputManager.InputState.FIRST_PERSON:
		return
	
	if hovering:
		if debug:
			DebugDraw2D.set_text("hovering", hovering.name, 0, Color.WHITE, 0.0)
		if Input.is_action_just_pressed("interact") && hovering.has_method("interact"):
			hovering.interact()

func is_interactable(node: Node) -> bool:
	if node is not CollisionObject3D:
		return false
	
	var collision_object: CollisionObject3D = node as CollisionObject3D
	
	if collision_object.collision_layer & blocker_mask != 0:
		return false
	
	return true

func _update_hovering() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin: Vector3 = pcam.global_position
	var direction: Vector3 = pcam.global_basis * Vector3.FORWARD
	
	# Simple raycast first for pixel-perfect object picking
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, origin + reach_distance * direction, interactable_mask | blocker_mask)
	ray_query.collide_with_areas = true
	
	var ray_results: Dictionary = space_state.intersect_ray(ray_query)
	if ray_results.size() > 0:
		var node: Node3D = ray_results["collider"]
		if is_interactable(node):
			hovering = node as CollisionObject3D
			return
	
	# If the raycast fails, follow up with a spherecast to give some extra leniency
	var sphere_query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	sphere_query.shape = sphere_shape
	sphere_query.transform = Transform3D(Basis.IDENTITY, origin)
	sphere_query.motion = reach_distance * direction
	sphere_query.collision_mask = interactable_mask | blocker_mask
	sphere_query.collide_with_areas = true
	
	var motion_results: PackedFloat32Array = space_state.cast_motion(sphere_query)
	if motion_results.size() >= 2 && motion_results[1] < 1.0:
		sphere_query.transform.origin += sphere_query.motion * motion_results[1]
	var sphere_results: Array[Dictionary] = space_state.intersect_shape(sphere_query, 1)
	if sphere_results.size() > 0:
		var node: Node3D = sphere_results[0]["collider"]
		if is_interactable(node):
			hovering = node as CollisionObject3D
			return
	
	hovering = null
