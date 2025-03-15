class_name PageVisual extends ItemVisual

@onready var label_3d: Label3D = %Label3D

var _page_data: PageData = null

func _on_item_data_set() -> void:
	_page_data = _item_data as PageData
	label_3d.text = str(_page_data.multiplier)
