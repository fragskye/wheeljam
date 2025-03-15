class_name DemonFaceVisual extends Node3D

@onready var eye_left: Node3D = %EyeLeft
@onready var eye_right: Node3D = %EyeRight
@onready var lower_mouth: Node3D = %LowerMouth
@onready var upper_mouth: Node3D = %UpperMouth

@export var update_framerate: float = 10.0 ## Fixed lower framerate to animate at

var data: DemonData = null
var _face: DemonFace = null

# The full range of X positions that the mouth's Line3Ds make up. Used to correctly interpret the mouth inner-outer curves
var _lower_mouth_x_min: float = INF
var _lower_mouth_x_max: float = -INF
var _upper_mouth_x_min: float = INF
var _upper_mouth_x_max: float = -INF

var _update_delay: float = 0.0
var _variance_spike_delay: float = INF
var _variance_spike_duration: int = 0

func _ready() -> void:
	for line: Line3D in lower_mouth.get_children():
		_lower_mouth_x_min = min(_lower_mouth_x_min, line.position.x)
		_lower_mouth_x_max = max(_lower_mouth_x_max, line.position.x)
	for line: Line3D in upper_mouth.get_children():
		_upper_mouth_x_min = min(_upper_mouth_x_min, line.position.x)
		_upper_mouth_x_max = max(_upper_mouth_x_max, line.position.x)

func set_face(face: DemonFace) -> void:
	_face = face
	if _variance_spike_delay == INF:
		_variance_spike_delay = randf_range(_face.variance_spike_delay_min, _face.variance_spike_delay_max)

func _process(delta: float) -> void:
	while _update_delay < 0.0:
		_update_delay = maxf(0.0, _update_delay + 1.0 / update_framerate)
		var spike: bool = false
		while _variance_spike_delay < 0.0:
			_variance_spike_delay = maxf(0.0, _variance_spike_delay + randf_range(_face.variance_spike_delay_min, _face.variance_spike_delay_max))
			_variance_spike_duration = randi_range(_face.variance_spike_duration_min, _face.variance_spike_duration_max)
		if _variance_spike_duration > 0:
			_variance_spike_duration -= 1
			spike = true
		update_face(spike)
	_update_delay -= delta
	_variance_spike_delay -= delta

func update_face(spike: bool) -> void:
	var variance: float = _face.variance_spike if spike else _face.variance
	for line: Line3D in eye_left.get_children():
		line.position.y = _face.eyes_height
		line.rotation_degrees.z = -(90 + _face.eyes_tilt)
		set_line(line, -_face.eyes_inner, -_face.eyes_outer, variance)
	for line: Line3D in eye_right.get_children():
		line.position.y = _face.eyes_height
		line.rotation_degrees.z = 90 + _face.eyes_tilt
		set_line(line, -_face.eyes_inner, -_face.eyes_outer, variance)
	lower_mouth.scale.x = _face.lower_mouth_scale
	for line: Line3D in lower_mouth.get_children():
		var mouth_percent: float = remap(absf(remap(line.position.x, _lower_mouth_x_min, _lower_mouth_x_max, -1.0, 1.0)), 0.0, 1.0, 0.0, 1.0)
		var mouth_inner_outer: float = data.lower_mouth_inner_outer_curve.sample(mouth_percent)
		var mouth_bottom: float = lerpf(_face.lower_mouth_inner_bottom, _face.lower_mouth_outer_bottom, mouth_inner_outer)
		var mouth_top: float = lerpf(_face.lower_mouth_inner_top, _face.lower_mouth_outer_top, mouth_inner_outer)
		set_line(line, mouth_bottom, mouth_top, variance)
	upper_mouth.scale.x = _face.upper_mouth_scale
	for line: Line3D in upper_mouth.get_children():
		var mouth_percent: float = remap(absf(remap(line.position.x, _upper_mouth_x_min, _upper_mouth_x_max, -1.0, 1.0)), 0.0, 1.0, 0.0, 1.0)
		var mouth_inner_outer: float = data.upper_mouth_inner_outer_curve.sample(mouth_percent)
		var mouth_bottom: float = lerpf(_face.upper_mouth_inner_bottom, _face.upper_mouth_outer_bottom, mouth_inner_outer)
		var mouth_top: float = lerpf(_face.upper_mouth_inner_top, _face.upper_mouth_outer_top, mouth_inner_outer)
		set_line(line, mouth_bottom, mouth_top, variance)

func set_line(line: Line3D, bottom: float, top: float, variance: float) -> void:
	line.points[0] = Vector3(randf_range(-variance, variance), bottom + randf_range(-variance, variance), 0.0)
	line.points[1] = Vector3(randf_range(-variance, variance), top + randf_range(-variance, variance), 0.0)
