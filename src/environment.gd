extends Node3D

@onready var book_store: AmbienceArea3D = %BookStore

func _ready() -> void:
	# HACK sometimes it thinks the player starts in the outside area for some reason
	await get_tree().physics_frame
	book_store.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().physics_frame
	book_store.process_mode = Node.PROCESS_MODE_INHERIT
