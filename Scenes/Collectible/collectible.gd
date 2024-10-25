extends Area2D

class_name Collectible

@export var pointValue: int = 1

signal granted_points(points: int)
signal collected()

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is BallEntity:
		collected.emit()
		if Globals.ENABLE_SIMPLE_COLLECTIBLES:
			destroy(true)
		else:
			body_entered.disconnect(_on_body_entered)
			body.inventory.add_item(self)
	else:
		return
		
func destroy(grantPoints: bool = false) -> void:
	if grantPoints:
		granted_points.emit(pointValue)
	self.queue_free()
