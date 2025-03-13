class_name Item extends Area3D

@export var data: ItemData = null

var _pickup_anim_progress: float = 0.0
var _pickup_anim_p0: Transform3D = Transform3D.IDENTITY
var _pickup_anim_p1: Node3D = null
var _pickup_anim_p2: Node3D = null

func interact() -> void:
	SignalBus.item_picked_up.emit(self)
	collision_layer = 0

func _process(delta: float) -> void:
	if _pickup_anim_progress > 0.0:
		if _pickup_anim_progress < 1.0:
			global_transform = _pickup_anim_p0.interpolate_with(_pickup_anim_p1.global_transform, _pickup_anim_progress)
		else:
			global_transform = _pickup_anim_p1.global_transform.interpolate_with(_pickup_anim_p2.global_transform, _pickup_anim_progress - 1.0)

func play_pickup_anim(target_start: Node3D, target_end: Node3D) -> void:
	_pickup_anim_progress = 0.0
	_pickup_anim_p0 = global_transform
	_pickup_anim_p1 = target_start
	_pickup_anim_p2 = target_end
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "_pickup_anim_progress", 1.0, 0.6)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "_pickup_anim_progress", 2.0, 0.3)
	tween.tween_callback(queue_free)
