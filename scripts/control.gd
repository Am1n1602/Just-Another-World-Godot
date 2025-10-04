extends Control

@onready var play_button = %Play
@onready var exit_button = %Exit
@onready var credits= %Credits
@onready var current=$"CurrentScoreContainer/CurrentScoreLabel"
@onready var highscore=$"HighScoreContainer/HighScoreLabel"
@onready var fade_overlay = $FadeOverlay
@onready var credits_overlay: Control = $CreditsOverlay

func _ready():
	# Make fade overlay fully transparent
	fade_overlay.color = Color(0,0,0,0)
	update_score_labels()
	play_button.pressed.connect(on_play_pressed)
	exit_button.pressed.connect(quit)
	credits.pressed.connect(show_credits)
	credits_overlay.hide()

func quit():
	get_tree().quit()

func show_credits():
	play_button.hide()
	exit_button.hide()
	credits.hide()
	highscore.hide()
	current.hide()
	credits_overlay.show()
	credits_overlay.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(credits_overlay, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func on_play_pressed():
	play_button.disabled = true
	exit_button.disabled = true
	credits.disabled = true
	play_button.hide()
	exit_button.hide()
	highscore.hide()
	current.hide()
	credits.hide()
	
	var tween = create_tween()
	var start_color = fade_overlay.color
	var end_color = Color(0,0,0,1)  # fully black
	tween.tween_property(fade_overlay, "color", end_color, 0.8).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.connect("finished", Callable(self, "_on_fade_complete"))

func _on_fade_complete():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
func update_score_labels():
	current.bbcode_enabled = true
	current.bbcode_text = "[center][color=white]Last Score: %d[/color][/center]" % Global.previous_score
	
	highscore.bbcode_enabled = true
	highscore.bbcode_text = "[center][color=white]High Score: %d[/color][/center]" % Global.high_score
	
func _unhandled_input(event):
	if credits_overlay.visible:
		if event is InputEventKey and event.pressed:
			credits_overlay.hide()
			play_button.show()
			exit_button.show()
			credits.show()
			highscore.show()
			current.show()
