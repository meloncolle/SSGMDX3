extends Control

# todo: what?? dont put this here man
var stroke_penalty = 25
var fuel_bonus = 0.1

@onready var retryButton: Button = $RetryButton
@onready var quitButton: Button = $QuitButton

var died: bool
var points: int
var fuel_remaining: float
var strokes: int
var final_score: int
var end_time: String

func _ready() -> void:
	pass
	
func calc_score() -> int:
	return roundi(points * maxf(1.0, (fuel_remaining * fuel_bonus)) - (strokes * stroke_penalty))
	
func show_results(_died: bool, _points: int, _fuel_remaining: float, _strokes: int) -> void:
	died = _died
	points = _points
	fuel_remaining = _fuel_remaining
	strokes = _strokes
	
	end_time = Time.get_datetime_string_from_system()

	final_score = calc_score()
	
	# todo: fix
	#var level_name: String = Globals.sceneController.levelPath.split("/")[-1].split(".")[0]
	var level_name := "LEVEL_NAME"

	var new_hi_score: int = Config.add_new_score(level_name, final_score, end_time)
	
	$Clear.text = level_name + " CLEARED!!!"
	
	$Results/PointsCollected.text = "Points Collected: \t%d" % points
	$Results/FuelBonus.text = "Fuel Bonus: \tx%d" % (fuel_remaining * fuel_bonus)
	$Results/StrokePenalty.text = "Stroke Penalty: \t-%d" % (strokes * stroke_penalty) 
	$Results/Score.text = "[center]%d[/center]" % final_score
	
	var hi_scores = Config.data.get_value("Scores", level_name, [])
	
	var children = $HiScores/Scores.get_children()
	for i in Globals.MAX_SCORES_PER_LEVEL:
		var score := "----"
		var date := ""
		if i < hi_scores.size():
			score = str(hi_scores[i][0])
			date = hi_scores[i][1]
			if i == new_hi_score:
				score = "[color=#11ff01]%s[/color]" % score
				date = "[color=#11ff01]%s[/color]" % date
				
		children[i].text = score
		children[i].get_node("Date").text = date
	
	$AnimationPlayer.play("show")
