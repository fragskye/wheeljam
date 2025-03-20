class_name Enemy extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

@export var move_slow_speed: float = 5.0
@export var move_fast_speed: float = 5.0
@export var move_smoothing: float = 0.1

@export_flags_3d_physics var los_blocker_mask: int = 0xFFFFFFFF

var target: Node3D = null
var dismissed: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if target == null:
		target = Global.player
	var target_is_player: bool = target == Global.player
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var raycast_offset: Vector3 = Vector3(0.0, 1.5, 0.0)
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(global_position + raycast_offset, target.global_position + raycast_offset, los_blocker_mask)
	var ray_results: Dictionary = space_state.intersect_ray(ray_query)
	var los_blocked: bool = ray_results.size() > 0
	var fast: bool = !target_is_player || !los_blocked
	var move_speed: float = move_fast_speed if fast else move_slow_speed

	var destination: Vector3 = navigation_agent_3d.get_next_path_position()
	var direction: Vector3 = (destination - global_position).normalized()
	direction.y = 0.0
	direction = direction.normalized()
	if direction:
		velocity.x = Util.temporal_lerp(velocity.x, direction.x * move_speed, move_smoothing, delta)
		velocity.z = Util.temporal_lerp(velocity.z, direction.z * move_speed, move_smoothing, delta)
	else:
		velocity.x = Util.temporal_lerp(velocity.x, 0.0, move_smoothing, delta)
		velocity.z = Util.temporal_lerp(velocity.z, 0.0, move_smoothing, delta)

	move_and_slide()

func recalculate_path() -> void:
	navigation_agent_3d.target_position = target.global_position

func interact() -> void:
	dismissed = true
	var player_to_enemy_dir: Vector3 = (global_position - Global.player.global_position).normalized()
	var best: float = -1.0
	var enemy_exits: Array[Node] = get_tree().get_nodes_in_group("enemy_exit")
	for enemy_exit_node: Node in enemy_exits:
		var enemy_exit: Node3D = enemy_exit_node as Node3D
		var player_to_exit_dir: Vector3 = (enemy_exit.global_position - Global.player.global_position).normalized()
		var dot_product: float = player_to_exit_dir.dot(player_to_enemy_dir)
		if dot_product > best:
			best = dot_product
			target = enemy_exit
	recalculate_path()

func _on_navigation_agent_3d_target_reached() -> void:
	if dismissed:
		queue_free()

func _on_hurt_box_body_entered(_body: Node3D) -> void:
	if !dismissed:
		NotificationLayer.hurt_flash()
		for i: int in range(0, 3):
			if Global.player.inventory[0] != null:
				var item: ItemData = null
				var item_idx: int = 0
				while item == null:
					item_idx = randi_range(0, Global.player.inventory.size() - 1)
					item = Global.player.inventory[item_idx]
				Global.player.inventory[item_idx] = null
			Global.player.flush_inventory()
		queue_free()
