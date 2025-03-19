class_name FootstepController extends Node3D

@export var footstep_distance: float = 1.0
@export var pitch_variation: float = 0.0
@export var footstep_audio: Array[AudioStream] = []
@export var footstep_sfx: AudioStreamPlayer3D = null

var _last_footstep_pos: Vector3 = Vector3.ZERO
var _last_footstep_time: float = 0.0

func _ready() -> void:
	_last_footstep_pos = global_position

func _process(delta: float) -> void:
	_last_footstep_time += delta
	
	var distance: float = global_position.distance_to(_last_footstep_pos)
	
	if distance >= footstep_distance:
		_last_footstep_pos = global_position
		footstep_sfx.stream = footstep_audio.pick_random()
		footstep_sfx.pitch_scale = randf_range(1.0 - pitch_variation * 0.5, 1.0 + pitch_variation * 0.5)
		footstep_sfx.play()
		_last_footstep_time = 0.0
	elif _last_footstep_time > 0.75:
		_last_footstep_pos = global_position
		_last_footstep_time = 0.0
