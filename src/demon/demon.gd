class_name Demon extends Node3D

@onready var eye_left: Node3D = %EyeLeft
@onready var eye_right: Node3D = %EyeRight
@onready var lower_mouth: Node3D = %LowerMouth
@onready var upper_mouth: Node3D = %UpperMouth

@export var face: DemonFace = null
@export var lower_mouth_inner_outer_curve: Curve = null
@export var upper_mouth_inner_outer_curve: Curve = null
@export var mouth_width: float = 1.2
@export var update_duration: float = 0.1

var _update_delay: float = 0.0
var _variance_spike_delay: float = 0.0
var _variance_spike_duration: int = 0

func _ready() -> void:
	_variance_spike_delay = randf_range(face.variance_spike_delay_min, face.variance_spike_delay_max)

func _process(delta: float) -> void:
	while _update_delay < 0.0:
		_update_delay += update_duration
		var spike: bool = false
		while _variance_spike_delay < 0.0:
			_variance_spike_delay += randf_range(face.variance_spike_delay_min, face.variance_spike_delay_max)
			_variance_spike_duration = randi_range(face.variance_spike_duration_min, face.variance_spike_duration_max)
		if _variance_spike_duration > 0:
			_variance_spike_duration -= 1
			spike = true
		update_face(spike)
	_update_delay -= delta
	_variance_spike_delay -= delta

func update_face(spike: bool) -> void:
	var variance: float = face.variance_spike if spike else face.variance
	for line: Line3D in eye_left.get_children():
		line.position.y = face.eyes_height
		line.rotation_degrees.z = -(90 + face.eyes_tilt)
		set_line(line, face.eyes_inner, face.eyes_outer, variance)
	for line: Line3D in eye_right.get_children():
		line.position.y = face.eyes_height
		line.rotation_degrees.z = 90 + face.eyes_tilt
		set_line(line, face.eyes_inner, face.eyes_outer, variance)
	lower_mouth.scale.x = face.lower_mouth_scale
	for line: Line3D in lower_mouth.get_children():
		var mouth_percent: float = remap(absf(line.position.x), 0.0, mouth_width * 0.5, 0.0, 1.0)
		var mouth_inner_outer: float = lower_mouth_inner_outer_curve.sample(mouth_percent)
		var mouth_bottom: float = lerpf(face.lower_mouth_inner_bottom, face.lower_mouth_outer_bottom, mouth_inner_outer)
		var mouth_top: float = lerpf(face.lower_mouth_inner_top, face.lower_mouth_outer_top, mouth_inner_outer)
		set_line(line, mouth_bottom, mouth_top, variance)
	upper_mouth.scale.x = face.upper_mouth_scale
	for line: Line3D in upper_mouth.get_children():
		var mouth_percent: float = remap(absf(line.position.x), 0.0, mouth_width * 0.5, 0.0, 1.0)
		var mouth_inner_outer: float = upper_mouth_inner_outer_curve.sample(mouth_percent)
		var mouth_bottom: float = lerpf(face.upper_mouth_inner_bottom, face.upper_mouth_outer_bottom, mouth_inner_outer)
		var mouth_top: float = lerpf(face.upper_mouth_inner_top, face.upper_mouth_outer_top, mouth_inner_outer)
		set_line(line, mouth_bottom, mouth_top, variance)

func set_line(line: Line3D, bottom: float, top: float, variance: float) -> void:
	line.points[0] = Vector3(randf_range(-variance, variance), bottom + randf_range(-variance, variance), 0.0)
	line.points[1] = Vector3(randf_range(-variance, variance), top + randf_range(-variance, variance), 0.0)
