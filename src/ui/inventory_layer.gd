class_name InventoryLayer extends CanvasLayer

@onready var inventory_menu: Control = %InventoryMenu
@onready var inventory_carousel: InventoryCarousel = %InventoryCarousel
@onready var inventory_sfx: AudioStreamPlayer2D = %InventorySFX

@export var inventory_open_audio: Array[AudioStream] = []
@export var inventory_close_audio: Array[AudioStream] = []

var _input_state_changed_this_frame: bool = false

func _ready() -> void:
	inventory_menu.hide()
	inventory_menu.process_mode = Node.PROCESS_MODE_DISABLED
	InputManager.input_state_changed.connect(_on_input_state_changed)
	
func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.INVENTORY:
		return
	
	if !_input_state_changed_this_frame && (Input.is_action_just_pressed("inventory") || Input.is_action_just_pressed("exit")):
		InputManager.pop_input_state()
	
	_input_state_changed_this_frame = false

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	_input_state_changed_this_frame = true
	
	match old_state:
		InputManager.InputState.INVENTORY:
			inventory_menu.hide()
			inventory_menu.process_mode = Node.PROCESS_MODE_DISABLED
			Global.player.flush_inventory()
			if old_state != new_state:
				inventory_sfx.stream = inventory_close_audio.pick_random()
				inventory_sfx.play()
	
	match new_state:
		InputManager.InputState.INVENTORY:
			Global.player.flush_inventory()
			inventory_menu.process_mode = Node.PROCESS_MODE_INHERIT
			inventory_menu.show()
			if old_state != new_state:
				inventory_sfx.stream = inventory_open_audio.pick_random()
				inventory_sfx.play()

func _on_close_button_pressed() -> void:
	if InputManager.get_input_state() != InputManager.InputState.INVENTORY:
		return
	
	InputManager.pop_input_state()
