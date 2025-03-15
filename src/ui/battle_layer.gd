class_name BattleLayer extends CanvasLayer

const WHEEL_SLICE: PackedScene = preload("res://prefabs/ui/wheel_slice.tscn")
const INVENTORY_ITEM: PackedScene = preload("res://prefabs/ui/inventory_item.tscn")

@onready var battle_menu: Control = %BattleMenu
@onready var inventory_carousel: InventoryCarousel = %InventoryCarousel
@onready var wheel: Control = %Wheel
@onready var wheel_center: Control = %WheelCenter

@export var wheel_slice_count: int = 0

var wheel_slices: Array[WheelSlice] = []

var _input_state_changed_this_frame: bool = false

var _selected_wheel_slice: int = 0
var _target_wheel_rotation: float = 0.0
var _wheel_rotation: float = 0.0

func _ready() -> void:
	update_slices()
	battle_menu.hide()
	battle_menu.process_mode = Node.PROCESS_MODE_DISABLED
	InputManager.input_state_changed.connect(_on_input_state_changed)
	
func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.BATTLE:
		return
	
	if Input.is_action_just_pressed("debug_test"):
		_target_wheel_rotation += 90.0
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "_wheel_rotation", _target_wheel_rotation, 1.0)
	
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
	while wheel_center.get_child_count() > wheel_slice_count:
		wheel_center.get_child(wheel_center.get_child_count() - 1).queue_free()
	
	var scale: float = (wheel.size.y * 0.4) / 512.0
	
	for wheel_slice_idx: int in wheel_slice_count:
		var wheel_slice: WheelSlice = null
		
		if wheel_center.get_child_count() <= wheel_slice_idx:
			wheel_slice = WHEEL_SLICE.instantiate()
			wheel_slice.index = wheel_slice_idx
			wheel_slice.pressed.connect(_on_wheel_slice_pressed)
			wheel_slices.push_back(wheel_slice)
			wheel_center.add_child(wheel_slice)
		else:
			wheel_slice = wheel_center.get_child(wheel_slice_idx)
		
		var percentage: float = float(wheel_slice_idx) / float(wheel_slice_count)
		var angle: float = percentage * TAU - (PI * 0.5) + deg_to_rad(_wheel_rotation)
		wheel_slice.position = (wheel.size.y * 0.3) * Vector2(cos(angle), sin(angle))
		wheel_slice.scale = scale * Vector2(1.0, 1.0)
		wheel_slice.angle = angle
		wheel_slice.queue_redraw()

func _on_inventory_carousel_item_pressed(data: ItemData) -> void:
	wheel_slices[_selected_wheel_slice].set_item(data)

func _on_wheel_slice_pressed(index: int, data: ItemData) -> void:
	_selected_wheel_slice = index
