class_name Item extends Area3D

@export var data: ItemData = null

func interact() -> void:
	SignalBus.item_picked_up.emit(self)
