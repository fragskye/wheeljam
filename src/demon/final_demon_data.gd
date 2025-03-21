class_name FinalDemonData extends DemonData

var moves_passed: int = 0

func ready() -> void:
	verdicts = default_verdicts.duplicate()
	var extra_verdict: DemonVerdict = verdicts.pop_back()
	verdicts.shuffle()
	verdicts.push_back(extra_verdict)
	SignalBus.battle_player_action_selected.connect(_on_battle_player_action_selected)

func next_phase() -> bool:
	moves_passed = 0
	Global.battle_layer.wheel_slice_count = 5
	Global.battle_layer._selected_wheel_slice = 4
	Global.battle_layer._needs_more_pages = true
	return true

func evaluate(index: int) -> DemonVerdict:
	if moves_passed < Global.battle_layer.wheel_slice_count:
		return default_verdicts[moves_passed]
	return verdicts[index]

func _on_battle_player_action_selected(index: int, _multiplier: float) -> void:
	if moves_passed < Global.battle_layer.wheel_slice_count:
		verdicts[index] = default_verdicts[moves_passed]
		moves_passed += 1
