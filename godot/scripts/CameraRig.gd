extends Node3D
## Orbit camera with mouse drag + scroll zoom.
## Drop on the CameraRig node; Camera3D must be a child.

@export var orbit_speed:  float = 0.007  # radians per pixel
@export var zoom_speed:   float = 2.0
@export var min_distance: float = 8.0
@export var max_distance: float = 120.0

var _dragging: bool  = false
var _yaw:      float = 0.0
var _pitch:    float = 0.45   # ~26° looking down

@onready var _cam: Camera3D = $Camera3D


func _ready() -> void:
	_update_camera()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_dragging = event.pressed
			MOUSE_BUTTON_WHEEL_UP:
				_zoom(-zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom(zoom_speed)

	elif event is InputEventMouseMotion and _dragging:
		_yaw   -= event.relative.x * orbit_speed
		_pitch  = clampf(_pitch - event.relative.y * orbit_speed, 0.05, PI * 0.48)
		_update_camera()


func _zoom(delta: float) -> void:
	var dist := _cam.position.length()
	dist = clampf(dist + delta, min_distance, max_distance)
	_cam.position = _cam.position.normalized() * dist
	_update_camera()


func _update_camera() -> void:
	rotation.y = _yaw
	rotation.x = _pitch
