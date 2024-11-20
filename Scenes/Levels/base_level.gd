extends Node2D

class_name BaseLevel

var state: Enums.LevelState:
	set = set_state

var balls: Array[Node]

var activeBallIndex: int = -1

@onready var cam: Node2D = $Camera2D
@onready var deathScreen: Control = $UI/DeathScreen

@onready var power: Node = $Power
@onready var powerMeter: Node2D = $UI/PowerMeter

var score: int = 0
@onready var scoreLabel: RichTextLabel = $UI/ScoreLabel

@onready var fuel: Node = $Fuel
@onready var fuelLabel: RichTextLabel = $UI/FuelLabel

var strokes: int = 0: set = set_strokes
@onready var strokeLabel: RichTextLabel = $UI/StrokesLabel

@export var infinite_fuel: bool = false

@onready var debugLabel: RichTextLabel = $UI/DebugLabel

func _ready():
	state = Enums.LevelState.INIT
	
	# Init UI label stuff
	if infinite_fuel:
		fuelLabel.visible = false
		$UI/InfinityFuel.visible = true
	scoreLabel.text = "Points: %d" % score
	fuelLabel.text = "Fuel: %0.2f%%" % fuel.fuel
	strokeLabel.text = "Strokes: %d" % strokes
	power.check_limit(fuel.fuel)

	# Populate ball list
	balls = get_tree().get_nodes_in_group("balls")
	assert(balls.size() > 0, "Level needs at least 1 ball!")
	update_ball_indices()
		
	# Set active ball
	for i in range(balls.size()):
		if activeBallIndex == -1:
			activeBallIndex =  i
			if balls[i].isFirstBall:
				break
		elif balls[i].isFirstBall:
			activeBallIndex = i
			break
	set_active_ball(activeBallIndex)
	
	# Hook up signals
	SignalBus.connect("earned_points", self.set_score)
	SignalBus.connect("pickup_fuel", func(val: float): fuel.fuel += val)
	SignalBus.connect("changed_fuel", _on_changed_fuel)
	SignalBus.connect("ball_destroyed", _on_ball_destroyed)
	SignalBus.connect("ball_stopped", _on_ball_stopped)
	SignalBus.lvl_ended.connect(end_level)
	
	# Hook up death screen buttons
	deathScreen.retryButton.pressed.connect(func(): SignalBus.lvl_restarted.emit())
	deathScreen.quitButton.pressed.connect(func(): SignalBus.lvl_exited.emit())

func _input(event):
	if Globals.disableInput:
		return
	
	match state:
		Enums.LevelState.WAIT_SWING:
			# SPACE DOWN to change active ball
			if event.is_action_pressed("ACTION"):
				if Globals.ENABLE_SWITCHING_BALLS:
					set_active_ball(activeBallIndex + 1)
				
			# LMB DOWN to start swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and event.pressed
			):
				state = Enums.LevelState.SWINGING
			
		Enums.LevelState.SWINGING:
			# LMB UP: do swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and not event.pressed
				):
				do_swing(power.power)
				state = Enums.LevelState.WAIT_STOP
				
		Enums.LevelState.WAIT_STOP:
			# SPACE DOWN to change active ball
			if event.is_action_pressed("ACTION"):
				if Globals.ENABLE_SWITCHING_BALLS:
					set_active_ball(activeBallIndex + 1)
			
			# RMB to brake/ release to stop brake
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_RIGHT 
			):
				balls[activeBallIndex].isBraking = event.pressed
				
		Enums.LevelState.DEAD:
			return

func do_swing(force: float):
	if balls.size() == 0:
		return
	
	var swing = (get_global_mouse_position() - balls[activeBallIndex].position).normalized()
	print(swing * power.force * power.power)
	balls[activeBallIndex].apply_central_impulse(swing * power.force * power.power * 500)
	balls[activeBallIndex].isStopped = false
	
	if !infinite_fuel:
		fuel.fuel -= power.power * Globals.MAX_FUEL_PER_SWING 
		
	strokes += 1

func set_active_ball(newIndex: int):
	# todo: ideally we'd want to be able to go back-forth and order by spatial distance btwn balls
	if newIndex >= balls.size() || newIndex < 0:
		newIndex = newIndex % balls.size()
	
	if newIndex != activeBallIndex:
		balls[activeBallIndex].isTargeted = false
	
	cam.set_target(balls[newIndex])
	
	activeBallIndex = newIndex
	balls[activeBallIndex].isTargeted = true
	
	if balls[activeBallIndex].isStopped:
		state = Enums.LevelState.WAIT_SWING
	else:
		state = Enums.LevelState.WAIT_STOP

func set_state(newState: Enums.LevelState):
	var _oldState := state
	
	match newState:
		Enums.LevelState.INIT:
			pass
			
		Enums.LevelState.WAIT_SWING:
			Globals.disableInput = false
			Globals.isPausable = true
			Globals.disableBoost = true
			balls[activeBallIndex].set_pointer(true)
			cam.allow_offset = true
			debugLabel.text = "[right]WAITING FOR SWING[/right]"
			
		Enums.LevelState.SWINGING:
			power.reset()
			power.isOscillating = true
			powerMeter.visible = true
			debugLabel.text = "[right]SWINGING[/right]"

		
		Enums.LevelState.WAIT_STOP:
			powerMeter.visible = false
			power.isOscillating = false
			Globals.disableBoost = false
			balls[activeBallIndex].set_pointer(false)
			cam.allow_offset = false
			debugLabel.text = "[right]WAITING FOR BALL STOP[/right]"

		
		Enums.LevelState.DEAD:
			Globals.disableInput = true
			Globals.isPausable = false
			deathScreen.visible = true
	state = newState

func set_score(newScore: int, baseScore: int = score):
	score = newScore + baseScore
	scoreLabel.text = "Points: %d" % score
	
func set_strokes(val: int):
	strokes = val
	strokeLabel.text = "Strokes: %d" % strokes

func _on_changed_fuel(newVal: float, _oldVal: float):
	fuelLabel.text = "Fuel: %0.2f%%" % newVal

func update_ball_indices():
	var ballCount := 0
	for b in balls:
		b.set_index(ballCount)
		ballCount += 1

func _on_ball_destroyed(destroyedIndex: int, _pos: Vector2, points: int = 0):
	if points != 0:
		set_score(points)
	
	balls.remove_at(destroyedIndex)
	if destroyedIndex <= activeBallIndex:
		activeBallIndex = max(activeBallIndex - 1, 0)
	update_ball_indices()	
	
	if balls.size() == 0:
		end_level(true)
	else:
		set_active_ball(activeBallIndex)
		
func _on_ball_stopped(index: int):
	if index == activeBallIndex:
		state = Enums.LevelState.WAIT_SWING


func end_level(died: bool = false):
	state = Enums.LevelState.DEAD
	deathScreen.show_results(died, score, fuel.fuel, strokes)
	#SignalBus.lvl_resumed.emit()
