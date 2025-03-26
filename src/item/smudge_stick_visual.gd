class_name SmudgeStickVisual extends ItemVisual

@export var _smudge_stick_data: SmudgeStickData = null

func _ready() -> void:
	update_visual()

func _on_item_data_set() -> void:
	_smudge_stick_data = _item_data as SmudgeStickData
	update_visual()

func _process(_delta: float) -> void:
	update_visual()

func update_visual() -> void:
	if _smudge_stick_data == null:
		return
