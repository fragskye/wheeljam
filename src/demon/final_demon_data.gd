class_name FinalDemonData extends DemonData

var moves_passed: int = 0

func ready() -> void:
	verdicts = default_verdicts.duplicate()
	var extra_verdict: DemonVerdict = verdicts.pop_back()
	verdicts.shuffle()
	verdicts.push_back(extra_verdict)
	SignalBus.battle_player_action_selected.connect(_on_battle_player_action_selected)
	Global.battle_layer.moves_per_turn = 4

func next_phase() -> bool:
	moves_passed = 0
	Global.battle_layer._moves_in_turn = 0
	for wheel_slice_idx: int in Global.battle_layer.wheel_slice_count:
		var wheel_slice: WheelSlice = Global.battle_layer._wheel_slices[wheel_slice_idx]
		wheel_slice.disabled = false
	Global.battle_layer.wheel_slice_count = 5
	Global.battle_layer._needs_more_pages = true
	Global.battle_layer.moves_per_turn = 5
	var tween: Tween = Global.battle_layer.get_tree().create_tween()
	tween.tween_interval(0.1)
	tween.tween_callback(Global.battle_layer.select_empty)
	return true

func evaluate(index: int) -> DemonVerdict:
	if moves_passed <= Global.battle_layer.wheel_slice_count:
		return default_verdicts[moves_passed - 1]
	return verdicts[index]

func _on_battle_player_action_selected(index: int, _multiplier: float) -> void:
	if moves_passed < Global.battle_layer.wheel_slice_count:
		verdicts[index] = default_verdicts[moves_passed]
	moves_passed += 1
	if moves_passed >= Global.battle_layer.wheel_slice_count:
		Global.battle_layer.moves_per_turn = 3
