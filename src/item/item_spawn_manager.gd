class_name ItemSpawnManager extends Node

@export var spawn_pools: Array[ItemSpawnPool] = []
var _spawn_pools: Array[Array] = []

func _ready() -> void:
	for spawn_pool: ItemSpawnPool in spawn_pools:
		var _spawn_pool: Array[Item] = spawn_pool.create_items()
		_spawn_pools.push_back(_spawn_pool)
	
	var item_spawns: Array[Node] = get_tree().get_nodes_in_group("item_spawn")
	item_spawns.shuffle()
	
	# Move all the floating item spawns to the front so they get taken up by the pages in the pool
	# Quick bubble sort since the built-in sorting isn't stable
	var i: int = 0
	while i < item_spawns.size() - 1:
		while i < 0:
			i += 1
		var item_spawn: ItemSpawn = item_spawns[i] as ItemSpawn
		var next_item_spawn: ItemSpawn = item_spawns[i + 1] as ItemSpawn
		if next_item_spawn.floating && !item_spawn.floating:
			item_spawns[i] = next_item_spawn
			item_spawns[i + 1] = item_spawn
			i -= 1
		else:
			i += 1
	
	for item_spawn_node: Node in item_spawns:
		if item_spawn_node is not ItemSpawn:
			push_error("%s in item_spawn group is not an instance of ItemSpawn" % item_spawn_node.get_path())
			continue
		
		var item_spawn: ItemSpawn = item_spawn_node as ItemSpawn
		
		if _spawn_pools[item_spawn.pool].size() <= 0:
			continue
		
		var item: Item = _spawn_pools[item_spawn.pool].pop_back()
		if item_spawn.floating:
			item.rotation_degrees.z += randf_range(-item_spawn.random_angle * 0.5, item_spawn.random_angle * 0.5)
		else:
			item.rotation_degrees.y += randf_range(-item_spawn.random_angle * 0.5, item_spawn.random_angle * 0.5)
			if item is Page:
				item.rotation_degrees.x = -90.0
		item_spawn.add_child(item)
		item.global_position += Vector3(randf_range(-item_spawn.random_position.x * 0.5, item_spawn.random_position.x * 0.5), randf_range(-item_spawn.random_position.y * 0.5, item_spawn.random_position.y * 0.5), randf_range(-item_spawn.random_position.z * 0.5, item_spawn.random_position.z * 0.5))
