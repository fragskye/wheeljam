class_name InventoryItem extends Control

signal pressed(data: ItemData)

@onready var drop_shadow: TextureRect = %DropShadow
@onready var item_renderer: ItemRenderer = %ItemRenderer

var data: ItemData = null

func _ready() -> void:
	set_item(null)

func set_item(item_data: ItemData) -> void:
	data = item_data
	
	if item_data == null:
		drop_shadow.hide()
	else:
		drop_shadow.show()
	
	item_renderer.set_item(item_data)

func _on_texture_button_pressed() -> void:
	pressed.emit(data)
