class_name InventoryCarousel extends Control

const INVENTORY_ITEM: PackedScene = preload("res://prefabs/ui/inventory_item.tscn")

signal item_pressed(item: ItemData)

@onready var carousel: Control = %Carousel
@onready var carousel_target_left: Control = %CarouselTargetLeft
@onready var carousel_target_right: Control = %CarouselTargetRight

@export var hover_percentage: float = 0.0
@export var hover_fast_percentage: float = 0.0
@export var cycle_duration: float = 0.3
@export var cycle_fast_duration: float = 0.15
@export var carousel_items: int = 9
@export var carousel_target_scale: float = 1.0
@export var carousel_item_position: Curve
@export var carousel_item_scale: Curve
@export var carousel_item_alpha: Curve

var _carousel_rotation_percentage: float = 0.0
var animating: bool = false

func _ready() -> void:
	for carousel_idx: int in carousel_items:
		var carousel_item: InventoryItem = INVENTORY_ITEM.instantiate()
		carousel.add_child(carousel_item)
		carousel_item.pressed.connect(_on_carousel_item_pressed)
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	SignalBus.inventory_flushed.connect(_on_inventory_flushed)
	_update_item_positions()

func _process(_delta: float) -> void:
	var input_state: InputManager.InputState = InputManager.get_input_state()
	if input_state != InputManager.InputState.INVENTORY && input_state != InputManager.InputState.BATTLE:
		return
	
	_update_item_positions()
	
	if Input.is_action_pressed("inventory_left"):
		cycle_left(Input.is_action_pressed("inventory_speed_modifier"))
	
	if Input.is_action_pressed("inventory_right"):
		cycle_right(Input.is_action_pressed("inventory_speed_modifier"))
	
	# incredibly annoying: hovering callbacks weren't working when i tried to manage the hover areas using controls
	# so instead i have to do this mess of mouse position coordinate checks
	var hover_size: float = size.x * hover_percentage
	var hover_fast_size: float = size.x * hover_fast_percentage
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var left: float = global_position.x
	var right: float = global_position.x + size.x
	var top: float = global_position.y
	var bottom: float = global_position.y + size.y
	if mouse_pos.x >= left && mouse_pos.x <= right && mouse_pos.y >= top && mouse_pos.y <= bottom:
		if mouse_pos.x - left < hover_size:
			if mouse_pos.x - left < hover_fast_size:
				cycle_left(true)
			else:
				cycle_left(false)
		if right - mouse_pos.x < hover_size:
			if right - mouse_pos.x < hover_fast_size:
				cycle_right(true)
			else:
				cycle_right(false)

func cycle_left(fast: bool) -> void:
	if animating:
		return
	
	_get_middle_carousel_item().item_renderer.stop_animating()
	animating = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "_carousel_rotation_percentage", 1.0, cycle_fast_duration if fast else cycle_duration)
	tween.tween_callback(_post_cycle_left)

func _post_cycle_left() -> void:
	Global.player.set_inventory_selected(Global.player.inventory_selected - 1)
	_carousel_rotation_percentage = 0.0
	animating = false
	_update_inventory_items()
	_update_item_positions()

func cycle_right(fast: bool) -> void:
	if animating:
		return
	
	_get_middle_carousel_item().item_renderer.stop_animating()
	animating = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "_carousel_rotation_percentage", -1.0, cycle_fast_duration if fast else cycle_duration)
	tween.tween_callback(_post_cycle_right)

func _post_cycle_right() -> void:
	Global.player.set_inventory_selected(Global.player.inventory_selected + 1)
	_carousel_rotation_percentage = 0.0
	animating = false
	_update_inventory_items()
	_update_item_positions()

func _update_item_positions() -> void:
	var target_left: Vector2 = carousel_target_left.global_position
	var target_right: Vector2 = carousel_target_right.global_position
	var target_midpoint: Vector2 = target_left.lerp(target_right, 0.5)
	var target_offset: Vector2 = target_midpoint - target_left
	target_left = target_midpoint - target_offset * carousel_target_scale
	target_right = target_midpoint + target_offset * carousel_target_scale
	for carousel_idx: int in carousel_items:
		var percentage: float = (float(carousel_idx) + _carousel_rotation_percentage) / float(carousel_items - 1)
		var scale_percentage: float = remap(absf(percentage - 0.5), 0.5, 0.0, 0.0, 1.0)
		var carousel_item: Control = carousel.get_child(carousel_idx)
		carousel_item.global_position = target_left.lerp(target_right, carousel_item_position.sample(percentage))
		carousel_item.scale = (size.y / 512.0) * carousel_item_scale.sample(percentage) * Vector2(1.0, 1.0)
		carousel_item.modulate = Color(1.0, 1.0, 1.0, carousel_item_alpha.sample(percentage))
		carousel_item.z_index = carousel_items * roundi(remap(scale_percentage, 0.0, 1.0, 0.0, floorf(float(carousel_items - 1) * 0.5)))

func _update_inventory_items() -> void:
	var inventory_offset: int = -floori(float(carousel_items) * 0.5)
	for idx: int in carousel.get_child_count():
		var carousel_item: InventoryItem = carousel.get_child(idx)
		carousel_item.set_item(Global.player.get_inventory_item(Global.player.inventory_selected + idx + inventory_offset))
		carousel_item.item_renderer.stop_animating()
	_get_middle_carousel_item().item_renderer.start_animating()

func _get_middle_carousel_item() -> InventoryItem:
	return carousel.get_child(floori(float(carousel_items) * 0.5))

func _on_item_picked_up(_item: Item) -> void:
	_update_inventory_items()

func _on_inventory_flushed() -> void:
	_update_inventory_items()

func _on_carousel_item_pressed(data: ItemData) -> void:
	item_pressed.emit(data)
