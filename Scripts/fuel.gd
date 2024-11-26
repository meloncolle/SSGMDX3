extends Node

@export var maxFuel: float = 100.0
@export var startingFuel: float = maxFuel

func _ready():
	fuel = startingFuel
	
var fuel: float:
	set = set_fuel
	
func set_fuel(value: float) -> void:
	var newFuel: float = clamp(value, 0, maxFuel)
	SignalBus.changed_fuel.emit(newFuel, fuel)
	fuel = newFuel
