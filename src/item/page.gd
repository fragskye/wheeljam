class_name Page extends Item

@onready var pick_up_sfx: AudioStreamPlayer3D = %PickUpSFX
@onready var pick_up_sfx_moving_audio_source: MovingAudioSource = %PickUpSFXMovingAudioSource

@export var pick_up_audio: Array[AudioStream] = []

func _ready() -> void:
	super._ready()
	pick_up_sfx.stream = pick_up_audio.pick_random()

func interact() -> void:
	super.interact()
	pick_up_sfx.play()
