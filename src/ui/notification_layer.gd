extends CanvasLayer

const TOAST_BACKGROUND: Texture2D = preload("res://assets/ui/toast_background.png")
const TOAST_BACKGROUND_SHORT: Texture2D = preload("res://assets/ui/toast_background_short.png")

@onready var notification_menu: Control = %NotificationMenu
@onready var toast_label: Label = %ToastLabel
@onready var toast_animation_player: AnimationPlayer = %ToastAnimationPlayer
@onready var background_2: TextureRect = %Background2
@onready var background_1: TextureRect = %Background1

func _process(_delta: float) -> void:
	pass

func show_toast(text: String) -> void:
	var short: bool = text.length() <= 30
	background_1.texture = TOAST_BACKGROUND_SHORT if short else TOAST_BACKGROUND
	background_2.texture = TOAST_BACKGROUND_SHORT if short else TOAST_BACKGROUND
	toast_label.text = text
	toast_animation_player.play("toast_animation")
