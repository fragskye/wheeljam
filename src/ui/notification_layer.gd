extends CanvasLayer

@onready var notification_menu: Control = %NotificationMenu
@onready var toast_label: Label = %ToastLabel
@onready var toast_animation_player: AnimationPlayer = %ToastAnimationPlayer

func _process(_delta: float) -> void:
	pass

func show_toast(text: String) -> void:
	toast_label.text = text
	toast_animation_player.play("toast_animation")
