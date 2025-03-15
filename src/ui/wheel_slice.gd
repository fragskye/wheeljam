class_name WheelSlice extends Control

signal pressed(index: int, data: ItemData)

@onready var inventory_item: InventoryItem = %InventoryItem

@export var index: int = 0

func set_item(item_data: ItemData) -> void:
	inventory_item.set_item(item_data)

func _on_texture_button_pressed() -> void:
	pressed.emit(index, inventory_item.data)

func _on_inventory_item_pressed(data: ItemData) -> void:
	pressed.emit(index, data)

func _on_mouse_entered() -> void:
	SignalBus.battle_player_action_previewed.emit(index)
