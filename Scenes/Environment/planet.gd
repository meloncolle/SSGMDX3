@tool
extends StaticBody2D

@export_range(0.01, 4096, 0.1, "suffix: px") var radius = 150:
	set = set_radius
	
@onready var collider: CollisionShape2D = $CollisionShape2D

func _ready():
	set_radius(radius)

func set_radius(value: float) -> void:
	radius = value
	if collider != null:
		collider.shape.radius = radius
