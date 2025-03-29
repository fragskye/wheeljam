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
	Global.battle_layer.update_slices()
	Global.battle_layer.select_empty()
	return true
