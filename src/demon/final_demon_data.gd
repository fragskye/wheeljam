class_name FinalDemonData extends DemonData

var moves_passed: int = 0

func begin_battle() -> void:
	verdicts = default_verdicts.duplicate()
	SignalBus.battle_player_action_selected.connect(_on_battle_player_action_selected)

func next_phase() -> void:
	moves_passed = 0

func evaluate(index: int) -> DemonVerdict:
	if moves_passed < 4:
		return default_verdicts[moves_passed]
	return verdicts[index]

func _on_battle_player_action_selected(index: int) -> void:
	if moves_passed < 4:
		verdicts[index] = default_verdicts[moves_passed]
		moves_passed += 1
