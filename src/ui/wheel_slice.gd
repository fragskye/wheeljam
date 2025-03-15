class_name WheelSlice extends Control

signal pressed(index: int)

@onready var background: WheelSliceBackground = %Background
@onready var tint: WheelSliceBackground = %Tint

var index: int = 0
var angle: float = 0.0
var disabled: bool = false

func _process(_delta: float) -> void:
	background.rotation = angle
	tint.rotation = angle
	
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
