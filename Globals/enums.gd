class_name Enums

# For top-lvl scene manager thing
enum GameState {ON_START, IN_GAME, PAUSED}

# FOR SANDBOX MODE (CURRENT) ONLY USING FIRST 3 STAGES
enum LevelState {
	INIT,		# Initial state for loading stuff
	WAIT_SWING,		# Ready to select ball and swing
	SWINGING,	# Started swing, waiting for player to release
	WAIT_STOP, # Wait for ball to stop moving so we can swing again
	DEAD		# Fail state if all balls are destroyed
	}
