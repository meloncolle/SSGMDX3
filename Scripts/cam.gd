extends Camera2D

@export var target: Node2D = null:
	set = set_target
@export var followSpeed: float = 5
@export var zoomSpeed: float = 5
@export var zoomSensitivity: float = 0.1
@export var minZoom: float = 0.1
@export var maxZoom: float = 1.5

var zoomEnabled: bool = true
var zoomTarget: float:
	set = set_zoom_target

func _ready():
	zoomTarget = zoom.x

func _process(delta):
	if target != null:
		global_position = global_position.lerp(target.global_position, delta * followSpeed)
	var newZoom: float = lerp(zoom.x, zoomTarget, delta * followSpeed)
	zoom = Vector2(newZoom, newZoom)

func _input(event):
	if Globals.disableInput:
		return
	# Scroll to zoom
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && zoomEnabled:
			zoomTarget += zoomSensitivity
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && zoomEnabled:
			zoomTarget -= zoomSensitivity

func set_target(value: Node2D):
	target = value
	
func set_zoom_target(value: float):
	zoomTarget = clamp(value, minZoom, maxZoom)
