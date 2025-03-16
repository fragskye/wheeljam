class_name DemonInteract extends Area3D

func interact() -> void:
	SignalBus.battle_begin.emit()
	InputManager.push_input_state(InputManager.InputState.BATTLE)
