extends Node

@export var maxFuel: float = 100.0
@export var startingFuel: float = maxFuel

signal changed_fuel(newFuel: float, oldFuel: float)

func _ready():
	fuel = startingFuel
	
var fuel: float:
	set = set_fuel
	
func set_fuel(value: float) -> void:
	var newFuel: float = clamp(value, 0, maxFuel)
	changed_fuel.emit(newFuel, fuel)
	fuel = newFuel
