class_name DemonInteract extends Area3D

@onready var demon_pcam: PhantomCamera3D = %DemonPhantomCamera

func interact() -> void:
	SignalBus.battle_begin.emit()
	demon_pcam.priority = 2
	InputManager.push_input_state(InputManager.InputState.BATTLE)
