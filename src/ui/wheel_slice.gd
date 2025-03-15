class_name WheelSlice extends Control

signal pressed(index: int, data: ItemData)

@onready var background: TextureRect = $Background
@onready var inventory_item: InventoryItem = %InventoryItem

var index: int = 0
var angle: float = 0.0

func _process(_delta: float) -> void:
	#background.rotation = angle
	pass

func _draw() -> void:
	draw_arc(-272.0 * Vector2(cos(angle), sin(angle)), 256.0, angle + PI * -0.25, angle + PI * 0.25, 16, Color(0.1, 0.1, 0.1), 512.0)

func set_item(item_data: ItemData) -> void:
	inventory_item.set_item(item_data)

func _on_texture_button_pressed() -> void:
	pressed.emit(index, inventory_item.data)

func _on_inventory_item_pressed(data: ItemData) -> void:
	pressed.emit(index, data)

func preview() -> void:
	SignalBus.battle_player_action_previewed.emit(index)
