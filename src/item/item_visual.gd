class_name ItemVisual extends Node3D

var _item_data: ItemData = null

func set_item_data(item_data: ItemData) -> void:
	_item_data = item_data
	_on_item_data_set()

func _on_item_data_set() -> void:
	pass
