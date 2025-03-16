class_name CameraShake extends Node3D

@export var pcam: PhantomCamera3D = null
@export var noise: FastNoiseLite = null
@export_group("Rotation Scale", "rotation_scale_")
@export var rotation_scale_x: float = 0.0
@export var rotation_scale_y: float = 0.0
@export var rotation_scale_z: float = 0.0
@export_group("Position Scale", "position_scale_")
@export var position_scale_x: float = 0.0
@export var position_scale_y: float = 0.0
@export var position_scale_z: float = 0.0

var shake_amount: float = 0.0

var shake_tween: Tween = null

var _time: float = 0.0

func shake(amount: float, duration: float, ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR) -> void:
	if shake_tween != null && shake_tween.is_running():
		shake_tween.stop()
	shake_amount = amount
	shake_tween = get_tree().create_tween()
	shake_tween.set_ease(ease)
	shake_tween.set_trans(trans)
	shake_tween.tween_property(self, "shake_amount", 0.0, duration)

func _process(delta: float) -> void:
	_time += delta * 10.0
	
	position = Vector3(shake_amount * position_scale_x * (noise.get_noise_2d(_time, 0.0) * 2.0 - 1.0), shake_amount * position_scale_y * (noise.get_noise_2d(_time, 1.0) * 2.0 - 1.0), shake_amount * position_scale_z * (noise.get_noise_2d(_time, 2.0) * 2.0 - 1.0))
	rotation_degrees = Vector3(shake_amount * position_scale_x * (noise.get_noise_2d(_time, 3.0) * 2.0 - 1.0), shake_amount * position_scale_y * (noise.get_noise_2d(_time, 4.0) * 2.0 - 1.0), shake_amount * position_scale_z * (noise.get_noise_2d(_time, 5.0) * 2.0 - 1.0))
