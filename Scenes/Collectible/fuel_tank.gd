extends Area2D

class_name Fuel

@export var fuelValue: float = 25.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("balls"):
			destroy()
	else:
		return

func destroy() -> void:
	SignalBus.pickup_fuel.emit(fuelValue)
	self.queue_free()
