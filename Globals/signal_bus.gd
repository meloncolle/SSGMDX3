extends Node

signal changed_fuel(newFuel: float, oldFuel: float)
signal changed_power(newPower: float)

signal ball_destroyed(index: int, destroyer: Node2D)

signal pickup_points()
signal pickup_fuel(fuel: float)

signal earned_points(points: int)

signal level_ended()
