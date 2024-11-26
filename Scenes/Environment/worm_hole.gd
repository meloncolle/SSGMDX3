@tool

extends Area2D

## The wormhole that this one warps you to
@export var warpTarget: Area2D = null
@export_range(0.01, 4096, 0.1, "suffix: px") var radius = 150:
	set = set_radius

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

func _ready():
	collider.shape = collider.shape.duplicate()
	set_radius(radius)
	if not Engine.is_editor_hint():
		assert(warpTarget != null, "Wormhole \"" + name + "\" needs to have warp target assigned")


func _on_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.warp(self, warpTarget)
		
func _on_center_exited(body: Node2D) -> void:
	if body.is_in_group("balls"):
		body.lastWarpSource = null

#-----------------------------------------------

func set_radius(value: float) -> void:
	radius = value
	if collider != null:
		collider.shape.radius = radius
	if sprite != null:
		var scaleFactor: float = value / 100
		sprite.scale = Vector2(scaleFactor, scaleFactor)
