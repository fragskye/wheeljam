class_name PageVisual extends ItemVisual

@onready var page_mesh: MeshInstance3D = %PageMesh
@onready var multiplier_label: Label3D = %MultiplierLabel
@onready var multiplier_label_shadow: Label3D = %MultiplierLabelShadow
@onready var burning_label: Label3D = %BurningLabel
@onready var pending_burn_label: Label3D = %PendingBurnLabel

var _page_data: PageData = null

func _on_item_data_set() -> void:
	_page_data = _item_data as PageData
	update_visual()

func _process(_delta: float) -> void:
	update_visual()

func update_visual() -> void:
	page_mesh.set_instance_shader_parameter("page", roundi(_page_data.multiplier))
	multiplier_label.text = "%.fx" % _page_data.multiplier
	multiplier_label_shadow.text = multiplier_label.text
	if _page_data.pending_burn:
		pending_burn_label.show()
	else:
		pending_burn_label.hide()
	if _page_data.burning:
		burning_label.show()
	else:
		burning_label.hide()
