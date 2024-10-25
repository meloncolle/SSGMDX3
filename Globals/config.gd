extends Node

#----------------CONFIG LOAD/SAVE--------------------#
var data = ConfigFile.new()


func _init() -> void:
	# Load data from a file.
	var _err = data.load(Globals.SAVE_PATH)

	# todo: Init volume values
	#for key in ["BGM", "SFX"]:
		#var val: float = data.get_value("Volume", key, 0.5)
		#AudioServer.set_bus_volume_db(AudioServer.get_bus_index(key), linear_to_db(val))

#return -1 if not high score, return placement if it was a high score
func add_new_score(level_name: String, new_score: int, end_time: String) -> int:
	var scores: Array = Config.data.get_value("Scores", level_name, [])
	
	if (scores.size() < Globals.MAX_SCORES_PER_LEVEL || 
		scores.any(func(e): return e[0] < new_score)):

		scores.append([new_score, end_time])
		scores.sort_custom(func(a, b): return a[0] > b[0])
		
		if scores.size() > Globals.MAX_SCORES_PER_LEVEL:
			scores = scores.slice(0, Globals.MAX_SCORES_PER_LEVEL)
			
		data.set_value("Scores", level_name, scores)
		data.save(Globals.SAVE_PATH)
		
	return scores.find([new_score, end_time])
