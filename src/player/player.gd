class_name Player extends CharacterBody3D

@onready var camera: Camera3D = %PlayerCamera
@onready var camera_rig: PlayerCameraRig = %PlayerCameraRig

var inventory: Array[ItemData] = []

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

func _ready() -> void:
	Global.player = self
	SignalBus.item_picked_up.connect(_on_item_picked_up)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (camera_rig.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_item_picked_up(item: Item) -> void:
	inventory.push_back(item.data)
