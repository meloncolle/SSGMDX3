extends Node

@export var starting_level: PackedScene = null

var gameState: Enums.GameState
var sceneInstance: Node = null

@onready var startMenu: Control = $Menus/Start
@onready var pauseMenu: Control = $Menus/Pause

func _ready():
	set_state(Enums.GameState.ON_START)
	startMenu.get_node("Panel/VBoxContainer/StartButton").pressed.connect(self._on_press_start)
	startMenu.get_node("Panel/VBoxContainer/ExitButton").pressed.connect(self._on_press_exit)
	pauseMenu.get_node("Panel/VBoxContainer/ResumeButton").pressed.connect(self._on_press_resume)
	pauseMenu.get_node("Panel/VBoxContainer/QuitButton").pressed.connect(self._on_press_quit)

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
	
func _on_press_resume():
	get_tree().paused = false
	set_state(Enums.GameState.IN_GAME)
	
func _on_press_quit():
	if (is_instance_valid(sceneInstance)):
		sceneInstance.queue_free()
	sceneInstance = null
	get_tree().paused = false
	set_state(Enums.GameState.ON_START)
