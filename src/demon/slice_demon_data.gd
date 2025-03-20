class_name SliceDemonData extends DemonData

func next_phase() -> bool:
	Global.battle_layer.wheel_slice_count = 5
	Global.battle_layer._selected_wheel_slice = 4
	Global.battle_layer._needs_more_pages = true
	return true
