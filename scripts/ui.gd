extends CanvasLayer

@onready var current_score_label = $Control/CurrentScore
@onready var high_score_label = $Control/HighScore
@onready var waves_left_label = $Control/WaveLeft
@onready var timer_label = $Control/Timer

var elapsed_time := 0.0

func _process(delta: float) -> void:
	if Global.game_active:
		elapsed_time += delta
		timer_label.text = "Time: " + str(int(elapsed_time)) + "s"
	
	$Control/CurrentScore.visible = Global.show_wave_ui
	$Control/HighScore.visible = Global.show_wave_ui
	$Control/WaveLeft.visible = Global.show_wave_ui
	timer_label.visible = true 

	if Global.show_wave_ui:
		var waves_left = max(0, Global.max_wave - Global.current_wave)
		current_score_label.text = "Score: " + str(Global.current_score)
		high_score_label.text = "High Score: " + str(Global.high_score)
		waves_left_label.text = "Waves Left: " + str(waves_left)
