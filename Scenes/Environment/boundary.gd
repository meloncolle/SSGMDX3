@tool
extends Line2D

@onready var collider: CollisionPolygon2D = $Body2D/CollisionPolygon2D
@onready var staticBody: Node2D = $Body2D
@onready var fill: Polygon2D = $Polygon2D
@export_range(0, 100, 0.1) var bounce: float = 0:
	set = set_bounce

func _ready():
	_set("points", points)
	set_bounce(bounce)

func set_bounce(value: float):
	bounce = value
	if staticBody != null && staticBody is StaticBody2D:
		staticBody.physics_material_override.bounce = value

func _set(name, value):
	match name:
		"points":
			if collider != null:
				collider.polygon = value
				fill.polygon = value

# temp for death boundary only
func _on_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.destroy()
