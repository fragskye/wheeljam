class_name HUDLayer extends CanvasLayer

@onready var hud_menu: Control = %HUDMenu
@onready var crosshair: TextureRect = %Crosshair

@export var crosshair_texture: Texture2D = null
@export var crosshair_hover_texture: Texture2D = null

var _input_state_changed_this_frame: bool = false

func _ready() -> void:
	_on_input_state_changed(InputManager.get_input_state(), InputManager.get_input_state())
	InputManager.input_state_changed.connect(_on_input_state_changed)

func _process(_delta: float) -> void:
	if InputManager.get_input_state() != InputManager.InputState.FIRST_PERSON:
		return
	
	crosshair.texture = crosshair_hover_texture if Global.player.interaction_system.hovering != null else crosshair_texture
	
	_input_state_changed_this_frame = false

func _on_input_state_changed(old_state: InputManager.InputState, new_state: InputManager.InputState) -> void:
	_input_state_changed_this_frame = true
	
	match old_state:
		InputManager.InputState.FIRST_PERSON:
			hud_menu.hide()
			hud_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	match new_state:
		InputManager.InputState.FIRST_PERSON:
			hud_menu.process_mode = Node.PROCESS_MODE_INHERIT
			hud_menu.show()
