class_name ItemData extends Resource

enum ItemType { WHEEL_FRAGMENT, WHEEL_SPIN }

var type: ItemType = ItemType.WHEEL_FRAGMENT
@export var visual_scene: PackedScene = null

func get_item_name() -> String:
	return ""
