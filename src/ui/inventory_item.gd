class_name InventoryItem extends Control

@onready var drop_shadow: TextureRect = %DropShadow
@onready var item_renderer: ItemRenderer = %ItemRenderer

func _ready() -> void:
	set_item(null)

func set_item(item_data: ItemData) -> void:
	if item_data == null:
		drop_shadow.hide()
	else:
		drop_shadow.show()
	
	item_renderer.set_item(item_data)
