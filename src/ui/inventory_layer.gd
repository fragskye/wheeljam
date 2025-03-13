class_name InventoryLayer extends CanvasLayer

@onready var inventory_menu: Control = %InventoryMenu
@onready var inventory_carousel: InventoryCarousel = %InventoryCarousel

var _input_state_changed_this_frame: bool = false

func _ready() -> void:
	inventory_menu.hide()
	InputManager.input_state_changed.connect(_on_input_state_changed)
	
func _process(delta: float) -> void:
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
			Global.player.flush_inventory()
	
	match new_state:
		InputManager.InputState.INVENTORY:
			inventory_menu.show()

func _on_resume_button_pressed() -> void:
	if InputManager.get_input_state() != InputManager.InputState.INVENTORY:
		return
	
	InputManager.pop_input_state()
