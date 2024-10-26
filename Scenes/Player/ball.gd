extends RigidBody2D

class_name BallEntity

var isTargeted := false:
	set = set_target

## Set this to make the game target this ball on game start.[br]
## If none are set, the first ball in the tree is targeted.[br]
## If multiple are set, the first ball in the tree with this set is targeted.[br]
@export var isFirstBall := false

var pointer: Node2D = null
var powerMeter: Node2D = null

#todo: uncomment when re-adding warp	
#var lastWarpSource: WHEntity = null
#var warpTarget: WHEntity = null
var awaitingWarp: bool = false

@onready var inventory = $FollowTarget

var index: int = -1: # Position in main ball array... Needs to be externally updated...
	set = set_index

func _physics_process(_delta: float) -> void:
	if !Globals.disableInput && isTargeted && pointer != null:
		look_at(get_global_mouse_position())

func destroy(grantPoints: bool = false):
	SignalBus.ball_destroyed.emit(index, global_position)
	
	for item in inventory.items:
		item.destroy(grantPoints)
	
	self.queue_free()

#todo: uncomment when re-adding warp	
#func warp(source: WHEntity, target: WHEntity) -> bool:
	#if(lastWarpSource == target):
		## to stop infinite loop
		#return false
	#else:
		#lastWarpSource = source
		#warpTarget = target
		#awaitingWarp = true
		#return true
#
#func _integrate_forces(_state):
	#if awaitingWarp && warpTarget != null:
		#self.global_position = warpTarget.global_position
		#awaitingWarp = false
		#warpTarget = null

func set_target(value: bool=true):
	set_pointer(value)
	isTargeted = value

func set_index(value: int):
	index = value

func set_pointer(value: bool=true):
	if (is_instance_valid(pointer)):
		pointer.queue_free()
	if value:
		pointer = load("res://Scenes/UI/Pointer.tscn").instantiate()
		self.add_child(pointer)
	else:
		pointer = null
