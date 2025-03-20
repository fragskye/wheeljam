class_name ProgressBarrier extends AnimatableBody3D

@onready var move_sfx: AudioStreamPlayer3D = %MoveSFX

@export var demon_requirement: int = 0
@export var play_sfx: bool = true

var _moved: bool = false

func _ready() -> void:
	check_move()

func _process(_delta: float) -> void:
	check_move()

func check_move() -> void:
	if _moved || Global.game == null:
		return
	
	if Global.game.demon_index < demon_requirement:
		return
	
	_moved = true
	await get_tree().create_timer(2.5).timeout
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + Vector3(0.0, -3.1, 0.0), 5.0)
	if play_sfx:
		move_sfx.play()
		Global.player.camera_shake.shake(0.1, 5.0)
