class_name Item extends Area3D

@export var data: ItemData = null
@export var visual: ItemVisual = null

func _ready() -> void:
	if visual != null:
		visual.set_item_data(data)

func interact() -> void:
	SignalBus.item_picked_up.emit(self)
	collision_layer = 0

func play_pickup_anim(target_start: Node3D, target_end: Node3D) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_method(_pickup_anim.bind(global_transform, target_start, target_end), 0.0, 1.0, 0.6)
	tween.tween_method(_pickup_anim.bind(global_transform, target_start, target_end), 1.0, 1.0, 0.2)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(_pickup_anim.bind(global_transform, target_start, target_end), 1.0, 2.0, 0.3)
	tween.tween_callback(queue_free)

func _pickup_anim(progress: float, original_transform: Transform3D, target_start: Node3D, target_end: Node3D) -> void:
	# TODO: why the hell is this flickering when you turn the camera mid-animation
	# TODO update: oh dear god it appears PhantomCamera does not like physics interpolation and is making my camera rotation lag behind one frame 
	if progress < 1.0:
		global_transform = original_transform.interpolate_with(target_start.get_global_transform_interpolated(), progress)
	else:
		global_transform = target_start.get_global_transform_interpolated().interpolate_with(target_end.get_global_transform_interpolated(), progress - 1.0)
