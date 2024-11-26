extends Node

@export var starting_level: PackedScene = null

var gameState: Enums.GameState
var sceneInstance: Node = null

@onready var startMenu: Control = $Menus/Start
@onready var pauseMenu: Control = $Menus/Pause

func _ready():
	if Globals.ENABLE_COLLISION_DEBUG_IN_EXPORT:
		get_tree().set_debug_collisions_hint(true)
	
	set_state(Enums.GameState.ON_START)
	startMenu.startButton.pressed.connect(self._on_press_start)
	startMenu.exitButton.pressed.connect(self._on_press_exit)
	pauseMenu.resumeButton.pressed.connect(func(): SignalBus.lvl_resumed.emit())
	pauseMenu.restartButton.pressed.connect(func(): SignalBus.lvl_restarted.emit())
	pauseMenu.quitButton.pressed.connect(func(): SignalBus.lvl_exited.emit())
	
	SignalBus.lvl_exited.connect(_on_press_lvl_quit)
	SignalBus.lvl_restarted.connect(_on_press_lvl_restart)
	SignalBus.lvl_resumed.connect(_on_press_lvl_resume)

func _input (event: InputEvent):
	if(gameState != Enums.GameState.ON_START && event.is_action_pressed("ui_cancel")):
		get_tree().paused = !get_tree().paused
		
		match gameState:
			Enums.GameState.IN_GAME:
				set_state(Enums.GameState.PAUSED)
				
			Enums.GameState.PAUSED:
				set_state(Enums.GameState.IN_GAME)
	
func set_state(newState: Enums.GameState):
	match newState:
		Enums.GameState.ON_START:
			startMenu.visible = true
			pauseMenu.visible = false
			
		Enums.GameState.IN_GAME:
			startMenu.visible = false
			pauseMenu.visible = false
			
		Enums.GameState.PAUSED:
			pauseMenu.visible = true
			
	gameState = newState


func _on_press_start():
	sceneInstance = load(starting_level.resource_path).instantiate()
	self.add_child(sceneInstance)
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_exit():
	get_tree().quit()
	
func _on_press_lvl_resume():
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_lvl_restart():
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)
	if (is_instance_valid(sceneInstance)):
		sceneInstance.queue_free()
		await get_tree().process_frame
	sceneInstance = load(starting_level.resource_path).instantiate()
	self.add_child(sceneInstance)
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_lvl_quit():
	if (is_instance_valid(sceneInstance)):
		sceneInstance.queue_free()
	sceneInstance = null
	get_tree().paused = false
	set_state(Enums.GameState.ON_START)
