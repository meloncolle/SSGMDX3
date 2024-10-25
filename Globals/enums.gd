class_name Enums

# For top-lvl scene manager thing
enum GameState {ON_START, IN_GAME, PAUSED}

# FOR SANDBOX MODE (CURRENT) ONLY USING FIRST 3 STAGES
enum LevelState {
	INIT,		# Initial state for loading stuff
	READY,		# Ready to select ball and swing
	IN_SWING,	# Started swing, waiting for player to release
	DEAD		# Fail state if all balls are destroyed
	}
