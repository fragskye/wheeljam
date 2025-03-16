class_name Player extends CharacterBody3D

@onready var camera: Camera3D = %PlayerCamera
@onready var camera_rig: PlayerCameraRig = %PlayerCameraRig
@onready var camera_shake: CameraShake = %CameraShake

@export var inventory_minimum_slots: int = 7

@export var move_speed: float = 5.0

@export var move_smoothing_accel: float = 0.1
@export var move_smoothing_decel: float = 0.1

var inventory: Array[ItemData] = []
var inventory_selected: int = 0

func _ready() -> void:
	for i: int in inventory_minimum_slots:
		inventory.push_back(null)
	SignalBus.item_picked_up.connect(_on_item_picked_up)
	Global.player = self

func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.FIRST_PERSON:
		return
	
	if Input.is_action_just_pressed("pause"):
		InputManager.push_input_state(InputManager.InputState.MENU)
	
	if Input.is_action_just_pressed("inventory"):
		InputManager.push_input_state(InputManager.InputState.INVENTORY)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (camera_rig.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0.0
	direction = direction.normalized()
	if direction:
		velocity.x = Util.temporal_lerp(velocity.x, direction.x * move_speed, move_smoothing_accel, delta)
		velocity.z = Util.temporal_lerp(velocity.z, direction.z * move_speed, move_smoothing_accel, delta)
	else:
		velocity.x = Util.temporal_lerp(velocity.x, 0.0, move_smoothing_decel, delta)
		velocity.z = Util.temporal_lerp(velocity.z, 0.0, move_smoothing_decel, delta)

	move_and_slide()

func _on_item_picked_up(item: Item) -> void:
	inventory.push_back(item.data)
	flush_inventory()

func flush_inventory() -> void:
	var idx: int = 0
	while idx < inventory.size():
		if inventory[idx] == null:
			inventory.remove_at(idx)
			if idx < inventory_selected:
				inventory_selected -= 1;
			idx -= 1
		idx += 1
	
	var inventory_size: int = inventory.size()
	if inventory_size > 0:
		while inventory_selected < 0:
			inventory_selected += inventory_size
		while inventory_selected >= inventory_size:
			inventory_selected -= inventory_size
	
	for i: int in inventory_minimum_slots - inventory.size():
		inventory.push_back(null)
	
	SignalBus.inventory_flushed.emit()

func get_inventory_item(idx: int) -> ItemData:
	var inventory_size: int = inventory.size()
	while idx < 0:
		idx += inventory_size
	while idx >= inventory_size:
		idx -= inventory_size
	return inventory[idx]

func set_inventory_selected(selected: int) -> void:
	var inventory_size: int = inventory.size()
	while selected < 0:
		selected += inventory_size
	while selected >= inventory_size:
		selected -= inventory_size
	inventory_selected = selected
