class_name PageData extends ItemData

@export var multiplier: float = 1.0
@export var burning: bool = false
var pending_burn: bool = false

func get_item_name() -> String:
	return "Page %d" % ceili(multiplier)
