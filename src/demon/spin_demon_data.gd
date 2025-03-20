class_name SpinDemonData extends DemonData

@export var second_phase_spin_cycles: int = 1

func next_phase() -> bool:
	Global.battle_layer.cycles_per_turn = second_phase_spin_cycles
	return true
