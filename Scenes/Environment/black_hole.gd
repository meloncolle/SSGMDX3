@tool

extends Area2D

@export_range(0.01, 4096, 0.1, "suffix: px") var radius = 150:
	set = set_radius

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

func _ready():
	set_radius(radius)

func _on_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		# Grant any points in inventory
		body.destroy(true)
	else:
		return


#-----------------------------------------------

func set_radius(value: float) -> void:
	radius = value
	if collider != null:
		collider.shape.radius = radius
	if sprite != null:
		var scaleFactor: float = value / 100
		sprite.scale = Vector2(scaleFactor, scaleFactor)
