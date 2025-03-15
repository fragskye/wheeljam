class_name WheelSlice extends Control

signal pressed(index: int)

@onready var background: WheelSliceBackground = %Background
@onready var hover_outline: WheelSliceBackground = %HoverOutline
@onready var selected_outline: WheelSliceBackground = %SelectedOutline
@onready var tint: WheelSliceBackground = %Tint

var index: int = 0
var angle: float = 0.0
var hover_highlight: bool = false
var selected_highlight: bool = false
var disabled: bool = false

func _process(_delta: float) -> void:
	background.rotation = angle
	hover_outline.rotation = angle
	selected_outline.rotation = angle
	tint.rotation = angle
	
	if hover_highlight:
		hover_outline.show()
	else:
		hover_outline.hide()
	
	if selected_highlight:
		selected_outline.show()
	else:
		selected_outline.hide()
	
	if disabled:
		tint.show()
	else:
		tint.hide()

func _on_texture_button_pressed() -> void:
	if disabled:
		return
	pressed.emit(index)

func preview() -> void:
	SignalBus.battle_player_action_previewed.emit(index)

func _on_texture_button_mouse_entered() -> void:
	hover_highlight = true
	preview()

func _on_texture_button_mouse_exited() -> void:
	hover_highlight = false
