extends Camera2D

@export var target: Node2D = null:
	set = set_target
@export var zoomSpeed: float = 5
@export var zoomSensitivity: float = 0.1
@export var minZoom: float = 0.1
@export var maxZoom: float = 1.5

var zoomEnabled: bool = true
var zoomTarget: float:
	set = set_zoom_target

@export var max_offset = 100
var offset_target: Vector2 = Vector2.ZERO
var allow_offset := true:
	set = set_allow_offset

func _ready():	
	zoomTarget = zoom.x

func _process(delta):
	if target != null:
		var follow_speed = max(5, target.linear_velocity.length() / 200)
		global_position = global_position.lerp(target.global_position, delta * follow_speed)
	var newZoom: float = lerp(zoom.x, zoomTarget, delta * zoomSpeed)
	zoom = Vector2(newZoom, newZoom)
	
	offset = offset.lerp(offset_target, delta * 3)


func _input(event):
	if Globals.disableInput:
		return
	# Scroll to zoom
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && zoomEnabled:
			zoomTarget += zoomSensitivity
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && zoomEnabled:
			zoomTarget -= zoomSensitivity
			
	# Move camera a bit towards mouse for aiming
	if (event is InputEventMouseMotion):
		if allow_offset:
			offset_target = (get_global_mouse_position() - global_position) / Vector2(DisplayServer.window_get_size()) * 2.0 * max_offset

func set_target(value: Node2D):
	target = value
		
func set_allow_offset(value: bool):
	allow_offset = value
	if !value:
		# todo: make the camera smooth back to this offset nicer....
		offset_target = Vector2.ZERO
	
func set_zoom_target(value: float):
	zoomTarget = clamp(value, minZoom, maxZoom)
