class_name ItemSpawnGizmoPlugin extends EditorNode3DGizmoPlugin

var _page_mesh: BoxMesh = null
var _arrow_body_mesh: BoxMesh = null
var _arrow_head_mesh: PrismMesh = null
var _text_meshes: Array[TextMesh] = []

func _init() -> void:
	_page_mesh = BoxMesh.new()
	_page_mesh.size = Vector3(0.2, 0.3, 0.0)
	_arrow_body_mesh = BoxMesh.new()
	_arrow_body_mesh.size = Vector3(0.01, 0.1, 0.0)
	_arrow_head_mesh = PrismMesh.new()
	_arrow_head_mesh.size = Vector3(0.1, 0.1, 0.0)
	for i: int in range(0, 20):
		var text_mesh: TextMesh = TextMesh.new()
		text_mesh.text = str(i)
		text_mesh.depth = 0.0
		_text_meshes.push_back(text_mesh)
	create_material("main", Color(0.0, 1.0, 0.0))
	create_material("text", Color(2.0, 2.0, 2.0), false, true)

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()

	var node: Node3D = gizmo.get_node_3d()
	var item_spawn: ItemSpawn = node as ItemSpawn
	
	var page_transform: Transform3D = Transform3D.IDENTITY
	page_transform.origin = Vector3(0.0, 0.001, 0.0)
	var arrow_body_transform: Transform3D = Transform3D.IDENTITY
	arrow_body_transform.origin = Vector3(0.0, 0.001, -0.2)
	var arrow_head_transform: Transform3D = Transform3D.IDENTITY
	arrow_head_transform.origin = Vector3(0.0, 0.001, -0.3)
	var text_transform: Transform3D = Transform3D.IDENTITY
	text_transform.origin = Vector3(0.0, 0.002, 0.0)
	if !item_spawn.floating:
		page_transform.basis = page_transform.basis.rotated(Vector3(1.0, 0.0, 0.0), PI * -0.5)
		arrow_body_transform.basis = arrow_body_transform.basis.rotated(Vector3(1.0, 0.0, 0.0), PI * -0.5)
		arrow_head_transform.basis = arrow_head_transform.basis.rotated(Vector3(1.0, 0.0, 0.0), PI * -0.5)
		text_transform.basis = text_transform.basis.rotated(Vector3(1.0, 0.0, 0.0), PI * -0.5)
	else:
		page_transform.origin = Vector3(page_transform.origin.x, -page_transform.origin.z, page_transform.origin.y)
		arrow_body_transform.origin = Vector3(arrow_body_transform.origin.x, -arrow_body_transform.origin.z, arrow_body_transform.origin.y)
		arrow_head_transform.origin = Vector3(arrow_head_transform.origin.x, -arrow_head_transform.origin.z, arrow_head_transform.origin.y)
		text_transform.origin = Vector3(text_transform.origin.x, -text_transform.origin.z, text_transform.origin.y)

	gizmo.add_mesh(_page_mesh, get_material("main", gizmo), page_transform)
	gizmo.add_mesh(_arrow_body_mesh, get_material("main", gizmo), arrow_body_transform)
	gizmo.add_mesh(_arrow_head_mesh, get_material("main", gizmo), arrow_head_transform)
	gizmo.add_mesh(_text_meshes[item_spawn.pool], get_material("text", gizmo), text_transform)

func _has_gizmo(node: Node) -> bool:
	return node is ItemSpawn
