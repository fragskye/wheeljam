class_name PauseLayer extends CanvasLayer

@onready var pause_menu: Control = %PauseMenu

var _input_state_changed_this_frame: bool = false

func _ready() -> void:
	pause_menu.visible = false
	#pause_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	InputManager.input_state_changed.connect(_on_input_state_changed)

func _process(delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.MENU:
		return
	
	if !_input_state_changed_this_frame && Input.is_action_just_pressed("exit"):
		InputManager.pop_input_state()
	
	_input_state_changed_this_frame = false

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	_input_state_changed_this_frame = true
	
	match old_state:
		InputManager.InputState.MENU:
			pause_menu.visible = false
	
	match new_state:
		InputManager.InputState.MENU:
			pause_menu.visible = true

func _on_resume_button_pressed() -> void:
	if InputManager.get_input_state() != InputManager.InputState.MENU:
		return
	
	InputManager.pop_input_state()
