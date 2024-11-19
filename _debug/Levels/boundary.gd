@tool
extends Line2D

@onready var collider: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var staticBody: StaticBody2D = $StaticBody2D
@export_range(0, 100, 0.1) var bounce: float = 0:
	set = set_bounce

func _ready():
	_set("points", points)
	set_bounce(bounce)

func set_bounce(value: float):
	bounce = value
	if staticBody != null:
		staticBody.physics_material_override.bounce = value

func _set(name, value):
	match name:
		"points":
			if collider != null:
				collider.polygon = value
