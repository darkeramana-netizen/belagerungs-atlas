extends RefCounted
## GlacisBuilder — builds GLACIS (sloped stone sockel around castle base).

var style:   String = "crusader"
var scale_f: float  = 1.0

var _mat: StandardMaterial3D

func _init() -> void:
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = Color(0.42, 0.40, 0.36)
	_mat.roughness    = 0.92


func build(comp: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = comp.get("id", "glacis").replace("/", "_")

	var r_top := float(comp.get("rTop", 11.0)) * scale_f
	var r_bot := float(comp.get("rBot", 17.0)) * scale_f
	var h     := float(comp.get("h",    2.0))  * scale_f
	var py    := float(comp.get("y",    0.0))  * scale_f

	root.position.y = py

	# Truncated cone (frustum) using CylinderMesh
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius    = r_top
	cm.bottom_radius = r_bot
	cm.height        = h
	cm.radial_segments = 32
	mi.mesh = cm
	mi.material_override = _mat
	mi.position = Vector3(0, h * 0.5, 0)
	root.add_child(mi)

	# Physics
	var body := StaticBody3D.new()
	var csh  := CollisionShape3D.new()
	var cs   := CylinderShape3D.new()
	cs.radius = (r_top + r_bot) * 0.5
	cs.height = h
	csh.shape = cs
	body.position = mi.position
	body.add_child(csh)
	root.add_child(body)

	return root
