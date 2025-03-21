class_name SliceDemonData extends DemonData

func ready() -> void:
	verdicts = default_verdicts.duplicate()
	var extra_verdict: DemonVerdict = verdicts.pop_back()
	verdicts.shuffle()
	verdicts.push_back(extra_verdict)

func next_phase() -> bool:
	# game jam moment
	Global.battle_layer._moves_in_turn = 0
	for wheel_slice_idx: int in Global.battle_layer.wheel_slice_count:
		var wheel_slice: WheelSlice = Global.battle_layer._wheel_slices[wheel_slice_idx]
		wheel_slice.disabled = false
	Global.battle_layer.wheel_slice_count = 5
	Global.battle_layer._needs_more_pages = true
	var tween: Tween = Global.battle_layer.get_tree().create_tween()
	tween.tween_interval(0.1)
	tween.tween_callback(Global.battle_layer.select_empty)
	return true
