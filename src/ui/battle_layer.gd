class_name BattleLayer extends CanvasLayer

const WHEEL_SLICE: PackedScene = preload("res://prefabs/ui/wheel_slice.tscn")
const INVENTORY_ITEM: PackedScene = preload("res://prefabs/ui/inventory_item.tscn")

@onready var battle_menu: Control = %BattleMenu
@onready var inventory_carousel: InventoryCarousel = %InventoryCarousel
@onready var wheel: Control = %Wheel
@onready var wheel_slices: Control = %WheelSlices
@onready var wheel_wedges: Control = %WheelWedges

@export var wheel_slice_count: int = 0

var _wheel_slices: Array[WheelSlice] = []
var _wheel_wedges: Array[InventoryItem] = []

var _input_state_changed_this_frame: bool = false

var _selected_wheel_slice: int = 0
var _wheel_rotation: int = 0
var _wheel_rotation_visual_offset: float = 0.0

var _needs_more_pages: bool = true

func _ready() -> void:
	update_slices()
	battle_menu.hide()
	battle_menu.process_mode = Node.PROCESS_MODE_DISABLED
	InputManager.input_state_changed.connect(_on_input_state_changed)
	SignalBus.battle_player_turn_complete.connect(_on_battle_player_turn_complete)

func rotate_wheel(slices: int) -> void:
	_wheel_rotation += slices
	while _wheel_rotation < 0:
		_wheel_rotation += wheel_slice_count
	while _wheel_rotation >= wheel_slice_count:
		_wheel_rotation -= wheel_slice_count
	_wheel_rotation_visual_offset = slices * -90
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "_wheel_rotation_visual_offset", 0.0, 0.2)
	
func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.BATTLE:
		return
	
	if Input.is_action_just_pressed("debug_test"):
		rotate_wheel(1)
	
	update_slices()
	
	_input_state_changed_this_frame = false

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	_input_state_changed_this_frame = true
	
	match old_state:
		InputManager.InputState.BATTLE:
			battle_menu.hide()
			battle_menu.process_mode = Node.PROCESS_MODE_DISABLED
			Global.player.flush_inventory()
	
	match new_state:
		InputManager.InputState.BATTLE:
			Global.player.flush_inventory()
			battle_menu.process_mode = Node.PROCESS_MODE_INHERIT
			battle_menu.show()

func _on_close_button_pressed() -> void:
	if InputManager.get_input_state() != InputManager.InputState.BATTLE:
		return
	
	InputManager.pop_input_state()

func update_slices() -> void:
	while wheel_slices.get_child_count() > wheel_slice_count:
		wheel_slices.get_child(wheel_slices.get_child_count() - 1).queue_free()
	while _wheel_slices.size() > wheel_slice_count:
		_wheel_slices.pop_back()
	while wheel_wedges.get_child_count() > wheel_slice_count:
		wheel_wedges.get_child(wheel_wedges.get_child_count() - 1).queue_free()
	while _wheel_slices.size() > wheel_slice_count:
		_wheel_slices.pop_back()
	
	var scale: float = (wheel.size.y * 0.4) / 512.0
	
	for wheel_slice_idx: int in wheel_slice_count:
		var slice_percentage: float = float(wheel_slice_idx) / float(wheel_slice_count)
		var slice_angle: float = slice_percentage * TAU - (PI * 0.5)
		var wedge_percentage: float = float(wheel_slice_idx + _wheel_rotation) / float(wheel_slice_count)
		var wedge_angle: float = (wedge_percentage) * TAU - (PI * 0.5) + deg_to_rad(_wheel_rotation_visual_offset)
		
		var wheel_slice: WheelSlice = null
		
		if wheel_slices.get_child_count() <= wheel_slice_idx:
			wheel_slice = WHEEL_SLICE.instantiate()
			wheel_slice.index = wheel_slice_idx
			wheel_slice.pressed.connect(_on_wheel_slice_pressed)
			_wheel_slices.push_back(wheel_slice)
			wheel_slices.add_child(wheel_slice)
		else:
			wheel_slice = wheel_slices.get_child(wheel_slice_idx)
		
		var wheel_wedge: InventoryItem = null
		
		if wheel_wedges.get_child_count() <= wheel_slice_idx:
			wheel_wedge = INVENTORY_ITEM.instantiate()
			wheel_wedge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_wheel_wedges.push_back(wheel_wedge)
			wheel_wedges.add_child(wheel_wedge)
		else:
			wheel_wedge = wheel_wedges.get_child(wheel_slice_idx)
		
		wheel_slice.position = (wheel.size.y * 0.3) * Vector2(cos(slice_angle), sin(slice_angle))
		wheel_slice.scale = scale * Vector2(1.0, 1.0)
		wheel_slice.angle = slice_angle
		wheel_slice.selected_highlight = _needs_more_pages && wheel_slice_idx == _selected_wheel_slice
		
		wheel_wedge.position = (wheel.size.y * 0.3) * Vector2(cos(wedge_angle), sin(wedge_angle))
		wheel_wedge.scale = scale * Vector2(1.0, 1.0)

func _on_inventory_carousel_item_pressed(data: ItemData) -> void:
	if data is not PageData:
		return
	
	if _wheel_wedges[_selected_wheel_slice].data == null:
		_wheel_wedges[_selected_wheel_slice].set_item(data)
		Global.player.inventory[Global.player.inventory.find(data)] = null
		inventory_carousel.update_inventory_items()
		
		var empty_slot: bool = false
		for wheel_wedge: InventoryItem in _wheel_wedges:
			if wheel_wedge.data == null:
				empty_slot = true
		if !empty_slot:
			_needs_more_pages = false
			inventory_carousel.hide()
			inventory_carousel.process_mode = Node.PROCESS_MODE_DISABLED

func _on_wheel_slice_pressed(index: int) -> void:
	_selected_wheel_slice = index
	if !_needs_more_pages:
		_wheel_slices[index].disabled = true
		SignalBus.battle_player_action_selected.emit(index, get_wedge_page(index).multiplier)
		rotate_wheel(1)

func _on_battle_player_turn_complete() -> void:
	# TODO: check if any pages are burned
	pass

func get_wedge_page(slice: int) -> PageData:
	slice -= _wheel_rotation
	while slice < 0:
		slice += wheel_slice_count
	while slice >= wheel_slice_count:
		slice -= wheel_slice_count
	return _wheel_wedges[slice].data as PageData
