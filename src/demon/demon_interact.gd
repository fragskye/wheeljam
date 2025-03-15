class_name DemonInteract extends Area3D

@onready var demon_pcam: PhantomCamera3D = %DemonPhantomCamera

func interact() -> void:
	demon_pcam.priority = 2
	InputManager.push_input_state(InputManager.InputState.BATTLE)
