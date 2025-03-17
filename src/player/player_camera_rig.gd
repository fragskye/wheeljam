class_name PlayerCameraRig extends Node3D

@onready var pcam: PhantomCamera3D = %PhantomCamera3D
@onready var item_pickup_target_start: Node3D = $ItemPickupTargetStart
@onready var item_pickup_target_end: Node3D = $ItemPickupTargetEnd

@export var look_sensitivity: float = 1.0

var pitch: float = 0.0
var yaw: float = 0.0
var roll: float = 0.0

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	pass

func _ready() -> void:
	pitch = rotation_degrees.x
	yaw = rotation_degrees.y
	roll = rotation_degrees.z
	SignalBus.item_picked_up.connect(_on_item_picked_up)

func _unhandled_input(event: InputEvent) -> void:
	if InputManager.get_input_state() != InputManager.InputState.FIRST_PERSON:
		return
	
	if event is InputEventMouseMotion:
		var event_mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		pitch -= event_mouse_motion.screen_relative.y * 0.1 * look_sensitivity
		yaw -= event_mouse_motion.screen_relative.x * 0.1 * look_sensitivity
		normalize_angles()
		update_angles()

func normalize_angles() -> void:
	pitch = clampf(pitch, -89.0, 89.0)
	
	while yaw > 180.0:
		yaw -= 360.0
	
	while yaw < -180.0:
		yaw += 360.0

func update_angles() -> void:
	basis = Basis.IDENTITY
	rotate_object_local(Vector3.UP, deg_to_rad(yaw))
	rotate_object_local(Vector3.RIGHT, deg_to_rad(pitch))
	rotate_object_local(Vector3.FORWARD, deg_to_rad(roll))
	SignalBus.camera_rig_updated.emit(self)

func _on_item_picked_up(item: Item) -> void:
	item.play_pickup_anim(item_pickup_target_start, item_pickup_target_end)
