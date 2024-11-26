@tool
extends Area2D

## If this object can be gravity boosted
@export var boostEnabled := true
@export var allowNegativeGravity := true

## Radius of gravity field
@export_range(0.01, 4096, 0.1, "suffix: px") var radius = 150:
	set = set_radius
			
## Strength of gravity field
@export_range(Globals.MIN_GRAVITY, Globals.MAX_GRAVITY, 0.1, "suffix: px/s²") var gravityStrength = 980:
	set = set_grav_strength

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: ColorRect = $Sprite

static var pos_color: Color = Color.AQUAMARINE
static var neg_color: Color = Color.FUCHSIA
	
var baseGravity := 0.0
var isBoosting := false

func _ready():
	collider.shape = collider.shape.duplicate()
	sprite.material = sprite.material.duplicate()
	set_radius(radius)
	set_grav_strength(gravityStrength)
	update_color()
	
	baseGravity = gravityStrength

func _physics_process(delta):
	if not Engine.is_editor_hint():
		if isBoosting:
			if gravityStrength < Globals.GRAVITY_BOOST_LIMIT:
				gravityStrength += Globals.GRAVITY_BOOST_SPEED * delta * 100
				gravityStrength = clamp(gravityStrength, baseGravity, Globals.GRAVITY_BOOST_LIMIT)
		else:
			if gravityStrength > baseGravity:
				gravityStrength -= Globals.GRAVITY_BOOST_SPEED * delta * 100
				gravityStrength = clamp(gravityStrength, baseGravity, Globals.GRAVITY_BOOST_LIMIT)


func _input(event):
	if not Engine.is_editor_hint():
		if Globals.disableInput || Globals.disableBoost || !boostEnabled:
			return
		
		if (event is InputEventMouseButton 
			and event.button_index == MOUSE_BUTTON_LEFT 
			and event.pressed
			and is_point_inside(get_global_mouse_position())
		):
			isBoosting = true
		
		elif (event is InputEventMouseButton 
			and event.button_index == MOUSE_BUTTON_LEFT 
			and !event.pressed
		):
			isBoosting = false
			
		if (event is InputEventMouseMotion
			and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			isBoosting = is_point_inside(get_global_mouse_position())

func is_point_inside(point: Vector2) -> bool:
	return self.global_position.distance_to(point) < collider.shape.radius

func update_color() -> void:
	if sprite != null:
		sprite.material.set_shader_parameter("color", pos_color if gravityStrength >= 0 else neg_color)

# ----------SETTERS/GETTERS----------

func set_radius(value: float) -> void:
	radius = value
	if collider != null:
		collider.shape.radius = radius
	if sprite != null:
		sprite.size = Vector2.ONE * value * 2.0
		sprite.position = Vector2.ONE * value * -1.0
		sprite.material.set_shader_parameter("radius", value)
		
func set_grav_strength(value: float) -> void:
	if !allowNegativeGravity:
		value = max(0, value)
	
	gravityStrength = value
	if sprite != null:
		sprite.material.set_shader_parameter("strength", abs(value) / Globals.MAX_GRAVITY)

		if sign(self.gravity) != sign(value):
			update_color()
 
	self.gravity = gravityStrength
