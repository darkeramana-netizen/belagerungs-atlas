extends RefCounted
## HallBuilder — builds GABLED_HALL (residential / abbey / palas buildings).
## Mirrors buildGabledHall() from builders.js.

var style:   String = "crusader"
var scale_f: float  = 1.0

var _mat_stone: StandardMaterial3D
var _mat_roof:  StandardMaterial3D

func _init() -> void:
	_mat_stone = _stone_mat(Color(0.58, 0.54, 0.48))
	_mat_roof  = _stone_mat(Color(0.22, 0.18, 0.15))


func build(comp: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = comp.get("id", "hall").replace("/", "_")

	var px    := float(comp.get("x", 0.0)) * scale_f
	var pz    := float(comp.get("z", 0.0)) * scale_f
	var py    := float(comp.get("y", 0.0)) * scale_f
	var w     := float(comp.get("w", 6.2)) * scale_f
	var d     := float(comp.get("d", 3.2)) * scale_f
	var h     := float(comp.get("h", 3.0)) * scale_f
	var rot   := float(comp.get("rotation", 0.0))

	root.position  = Vector3(px, py, pz)
	root.rotation.y = rot

	var shell_t := maxf(0.14, minf(w, d) * 0.16)
	var door_w  := float(comp.get("doorW", maxf(0.5, w * 0.1)))  * scale_f
	var door_h  := float(comp.get("doorH", maxf(1.0, h * 0.52))) * scale_f

	# South face (+z): split for door
	var side := (w - door_w) * 0.5
	for sign in [-1.0, 1.0]:
		var panel := _box_mi(side, h, shell_t)
		panel.position = Vector3(sign * (door_w * 0.5 + side * 0.5), h * 0.5, d * 0.5 - shell_t * 0.5)
		root.add_child(panel)
	var above_h := h - door_h
	if above_h > 0.08:
		var top_p := _box_mi(w, above_h, shell_t)
		top_p.position = Vector3(0, door_h + above_h * 0.5, d * 0.5 - shell_t * 0.5)
		root.add_child(top_p)

	# North face (-z): solid
	var n_wall := _box_mi(w, h, shell_t)
	n_wall.position = Vector3(0, h * 0.5, -(d * 0.5 - shell_t * 0.5))
	root.add_child(n_wall)

	# East + West
	for sign in [-1.0, 1.0]:
		var sw := _box_mi(shell_t, h, d - shell_t * 2.0)
		sw.position = Vector3(sign * (w * 0.5 - shell_t * 0.5), h * 0.5, 0.0)
		root.add_child(sw)

	# Floor
	var fl := _box_mi(w - shell_t * 2, 0.12, d - shell_t * 2)
	fl.position = Vector3(0, 0.06, 0)
	root.add_child(fl)

	# Gabled roof
	_add_gabled_roof(root, w, d, h)

	# Physics
	_add_physics(root, w, d, h, shell_t)

	return root


func _add_gabled_roof(root: Node3D, w: float, d: float, h: float) -> void:
	# Simple triangular prism gabled roof
	var pitch := d * 0.4
	# Two slope panels approximated as tilted boxes
	for sign in [-1.0, 1.0]:
		var slope := MeshInstance3D.new()
		var sm := BoxMesh.new()
		sm.size = Vector3(w * 1.04, 0.12, sqrt(pitch * pitch + (d * 0.5) * (d * 0.5)) * 1.02)
		slope.mesh = sm
		slope.material_override = _mat_roof
		slope.position = Vector3(0, h + pitch * 0.5, sign * d * 0.25)
		slope.rotation.x = sign * atan2(pitch, d * 0.5)
		root.add_child(slope)

	# Ridge beam
	var ridge := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(w * 1.02, 0.14, 0.14)
	ridge.mesh = rm
	ridge.material_override = _mat_roof
	ridge.position = Vector3(0, h + pitch, 0)
	root.add_child(ridge)


func _add_physics(root: Node3D, w: float, d: float, h: float, shell_t: float) -> void:
	var panels := [
		[Vector3(0, h * 0.5, d * 0.5 - shell_t * 0.5),   Vector3(w, h, shell_t)],
		[Vector3(0, h * 0.5, -(d * 0.5 - shell_t * 0.5)), Vector3(w, h, shell_t)],
		[Vector3(w * 0.5 - shell_t * 0.5, h * 0.5, 0),   Vector3(shell_t, h, d)],
		[Vector3(-(w * 0.5 - shell_t * 0.5), h * 0.5, 0), Vector3(shell_t, h, d)],
	]
	for p in panels:
		var body := StaticBody3D.new()
		var csh  := CollisionShape3D.new()
		var bs   := BoxShape3D.new()
		bs.size = p[1]
		csh.shape = bs
		body.position = p[0]
		body.add_child(csh)
		root.add_child(body)


func _box_mi(w: float, h: float, d: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(w, h, d)
	mi.mesh = bm
	mi.material_override = _mat_stone
	return mi


func _stone_mat(albedo: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = 0.85
	m.metallic  = 0.0
	return m
