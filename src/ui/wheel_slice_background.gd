class_name WheelSliceBackground extends Control

@export var color: Color = Color.WHITE

func _draw() -> void:
	draw_arc(Vector2(-272.0, 0.0), 256.0, PI * -0.25, PI * 0.25, 16, color, 512.0)
