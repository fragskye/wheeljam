class_name WheelSliceBackground extends Control

@export var color: Color = Color.WHITE
@export var fill: bool = true

func _draw() -> void:
	var center: Vector2 = Vector2(-272.0, 0.0)
	draw_arc(center, 256.0 if fill else 512.0, PI * -0.25, PI * 0.25, 64, color, 512.0 if fill else 16.0)
	if !fill:
		draw_line(center, center + 512.0 * Vector2(cos(PI * -0.25), sin(PI * -0.25)), color, 16.0)
		draw_line(center, center + 512.0 * Vector2(cos(PI * 0.25), sin(PI * 0.25)), color, 16.0)
