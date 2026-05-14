extends CanvasLayer

var score = 0
var trick_display_timer = 0.0
var trick_display_duration = 2.0

func _ready():
	$TrickLabel.text = ""
	$ScoreLabel.text = "Score: 0"

func _process(delta):
	if trick_display_timer > 0:
		trick_display_timer -= delta
		if trick_display_timer <= 0:
			$TrickLabel.text = ""

func show_trick(trick_name: String, points: int):
	score += points
	$TrickLabel.text = trick_name + "\n+" + str(points)
	$ScoreLabel.text = "Score: " + str(score)
	trick_display_timer = trick_display_duration

func crash():
	score = 0
	$ScoreLabel.text = "Score: 0"
	$TrickLabel.text = "CRASHED!"
	trick_display_timer = trick_display_duration
