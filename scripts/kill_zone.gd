extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die_and_respawn"):
		body.die_and_respawn()
	else:
		timer.start()
	

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
