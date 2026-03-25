extends Node3D

## Main entry point.
## Set castle_id in the Inspector or via CLI argument --castle=<id>

@export var castle_id: String = "krak"
@export var data_dir:  String = "res://data/castles/"

@onready var castle_root: Node3D = $CastleRoot

const CastleLoader = preload("res://scripts/CastleLoader.gd")

func _ready() -> void:
	# Allow overriding castle via command-line: --castle=himeji
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--castle="):
			castle_id = arg.substr(9)

	_load_castle(castle_id)


func _load_castle(id: String) -> void:
	# Clear existing castle geometry
	for child in castle_root.get_children():
		child.queue_free()

	var model: Dictionary = CastleLoader.load_castle(data_dir, id)
	if model.is_empty():
		push_error("Castle '%s' not found in %s" % [id, data_dir])
		return

	var loader := CastleLoader.new()
	loader.build_into(castle_root, model)

	# Fit camera to castle radius
	var cam_rig: Node3D = $CameraRig
	if model.has("cameraRadius"):
		cam_rig.scale = Vector3.ONE * clampf(model.cameraRadius / 28.0, 0.5, 4.0)

	print("[Main] Loaded '%s' — %d components, style: %s" % [
		model.get("name", id),
		model.get("components", []).size(),
		model.get("style", "?"),
	])
