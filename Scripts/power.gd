extends Node

@export var force := 4.0 ## Multiplier for swing force
@export var meterSpeed := 7.5 ## Speed at which power meter oscillates

# Set this lower if we are low on fuel!
var limit: float = 1.0

signal changed_power(newPower: float)

var power: float:
	set = set_power

var isOscillating: bool = false
var meterTimer: float

func _ready():
	reset()

func _physics_process(delta):
	if isOscillating:
		meterTimer += delta
		set_power(limit * (1 + sin(meterTimer * meterSpeed)) * 0.5)

func reset():
	meterTimer = PI * 1.5
	set_power(0)

func set_power(value: float) -> void:
	power = value
	changed_power.emit(power)
	
func check_limit(fuel: float, _oldFuel: float = 0):
	if fuel < Globals.MAX_FUEL_PER_SWING:
		limit = fuel / Globals.MAX_FUEL_PER_SWING
	else:
		limit = 1.0
