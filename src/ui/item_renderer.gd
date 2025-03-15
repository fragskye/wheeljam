class_name ItemRenderer extends SubViewport

@onready var visual_root: Node3D = %VisualRoot

@export var animation_speed: float = 0.0

var _item_data: ItemData = null
var animating: bool = false
var rotation: float = 0.0

func _ready() -> void:
	render_target_update_mode = SubViewport.UPDATE_ONCE

func clear_item() -> void:
	_item_data = null
	stop_animating()
	for child: Node in visual_root.get_children():
		child.queue_free()

func get_item() -> ItemData:
	return _item_data

func set_item(item_data: ItemData) -> void:
	clear_item()
	_item_data = item_data
	if item_data != null:
		var visual: ItemVisual = item_data.visual_scene.instantiate()
		visual_root.add_child(visual)
		visual.set_item_data(item_data)

func start_animating() -> void:
	animating = true
	render_target_update_mode = SubViewport.UPDATE_ALWAYS

func stop_animating() -> void:
	animating = false
	rotation = 0.0
	visual_root.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	render_target_update_mode = SubViewport.UPDATE_ONCE

func _process(delta: float) -> void:
	if animating:
		rotation += animation_speed * delta
		while rotation >= 360.0:
			rotation -= 360.0
		visual_root.rotation_degrees.y = -rotation
