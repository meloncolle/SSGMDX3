extends Node2D

class_name BaseLevel

var state: Enums.LevelState:
	set = set_state

var balls: Array[BallEntity] = []

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

func _ready():
	state = Enums.LevelState.INIT
	
	# todo: this is entity checks and stuff that will need to be redone
	## Check for at least one black hole
	#var foundBH: bool = false
	#for bh in $BlackHoles.get_children():
		#if bh is BHEntity:
			#foundBH = true
			#break
	#assert(foundBH, "Expected at least one black hole in level")
	#
	## Check all wormholes have warp target assigned
	#for wh in $WormHoles.get_children():
		#if wh is WHEntity:
			##assert(wh.warpTarget != null, "Wormhole \"" + wh.name + "\" needs to have warp target assigned")
			#wh.connect("warped", func(): sfx.warpEnter.play())
	
	# Setup score signal for each collectible
	for c in $Collectibles.get_children():
		if c is Collectible:
			c.connect("granted_points", self.set_score)
		elif c is Fuel:
			c.connect("collect_fuel", func(val: float): fuel.fuel += val)
	
	# Populate ball list
	for b in $Planets.get_children():
		if b is BallEntity:
			balls.append(b)
	
	# Set up listener for when a ball is destroyed
	for b in balls:
		b.connect("ball_destroyed", self._on_ball_destroyed)
		
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
	
	assert(activeBallIndex != -1, "Ball not found in level")
	set_active_ball(activeBallIndex)
	
	# Hook up death screen buttons
	deathScreen.get_node("RetryButton").pressed.connect(_on_press_retry)
	deathScreen.get_node("QuitButton").pressed.connect(_on_press_quit)
	
	if Globals.sceneController != null:			
		# Hook up submit score button on pause menu
		# todo: make thsi better...
		Globals.sceneController.pauseMenu.submitButton.pressed.connect(end_level)
	
	power.connect("changed_power", $UI/PowerMeter/Mask/Bar._on_changed_power)
	fuel.connect("changed_fuel", _on_changed_fuel)
	fuel.connect("changed_fuel", power.check_limit)
	#_on_changed_fuel(fuel.fuel, fuel.fuel) # to trigger UI to appear
	
	if infinite_fuel:
		fuelLabel.visible = false
		$UI/InfinityFuel.visible = true
	
	state = Enums.LevelState.READY

func _input(event):
	if Globals.disableInput:
		return
	
	match state:
		Enums.LevelState.READY:
			# SPACE DOWN to change active ball
			if event.is_action_pressed("ACTION"):
				if Globals.ENABLE_SWITCHING_BALLS:
					set_active_ball(activeBallIndex + 1)
				
			# LMB DOWN to start swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and event.pressed
			):
				state = Enums.LevelState.IN_SWING
			
		Enums.LevelState.IN_SWING:
			# LMB UP: do swing
			if (event is InputEventMouseButton 
				and event.button_index == MOUSE_BUTTON_LEFT 
				and not event.pressed
				):
				do_swing(power.power)
				state = Enums.LevelState.READY
				
		Enums.LevelState.DEAD:
			return

func do_swing(force: float):
	if balls.size() == 0:
		return
	
	var swing = get_global_mouse_position() - balls[activeBallIndex].position
	# i think we have to multiply this by the camera zoom so the force is proportional?? weird
	balls[activeBallIndex].apply_central_impulse(swing * power.force * power.power * cam.zoom.y)
		
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

func set_state(newState: Enums.LevelState):
	var _oldState := state
	
	match newState:
		Enums.LevelState.INIT:
			scoreLabel.text = "Points: %d" % score
			fuelLabel.text = "Fuel: %0.2f%%" % fuel.fuel
			strokeLabel.text = "Strokes: %d" % strokes
			power.check_limit(fuel.fuel)
			
		Enums.LevelState.READY:
			Globals.disableInput = false
			Globals.isPausable = true
			power.isOscillating = false
			powerMeter.visible = false
			
		Enums.LevelState.IN_SWING:
			power.reset()
			power.isOscillating = true
			powerMeter.visible = true
		
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
		activeBallIndex -= 1
	update_ball_indices()	
	
	if balls.size() == 0:
		end_level(true)
	else:
		set_active_ball(activeBallIndex)

func end_level(died: bool = false):
	state = Enums.LevelState.DEAD
	deathScreen.show_results(died, score, fuel.fuel, strokes)
	# todo: fix this
	# also disable pausing
	Globals.sceneController._on_press_resume()

func _on_press_retry():
	if Globals.sceneController != null:
		# If running full game context
		Globals.sceneController._on_press_restart()
	else:
		# If running just the level scene
		get_tree().reload_current_scene()
	
func _on_press_quit():
	if Globals.sceneController != null:
		# If running full game context
		Globals.sceneController._on_press_quit()
	else:
		# If running just the level scene
		get_tree().quit()
