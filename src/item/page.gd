class_name Page extends Item

@onready var pick_up_sfx: AudioStreamPlayer3D = %PickUpSFX
@onready var pick_up_sfx_moving_audio_source: MovingAudioSource = %PickUpSFXMovingAudioSource

@export var pick_up_audio: Array[AudioStream] = []

func _ready() -> void:
	super._ready()
	pick_up_sfx.stream = pick_up_audio.pick_random()

func _process(_delta: float) -> void:
	# HACK HACK HACK HORRIBLE HACK SHIT GETS MUFFLED IF IT'S PICKED UP OVER A BORDER AND THIS FIXES IT!!!
	pick_up_sfx_moving_audio_source.global_position = Global.player.global_position

func interact() -> void:
	super.interact()
	pick_up_sfx.play()
