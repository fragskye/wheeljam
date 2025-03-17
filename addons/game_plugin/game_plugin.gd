@tool
class_name GamePlugin extends EditorPlugin

const ItemSpawnGizmoPlugin = preload("res://addons/game_plugin/item_spawn_gizmo_plugin.gd")

var item_spawn_gizmo_plugin = ItemSpawnGizmoPlugin.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(item_spawn_gizmo_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(item_spawn_gizmo_plugin)
