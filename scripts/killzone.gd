extends Area2D

@onready var timer: Timer = $Timer
@onready var death: CanvasLayer = %Death

func _on_body_entered(body: Node2D) -> void:
	timer.start()
	Engine.time_scale = 0.5
	Input.vibrate_handheld()
	body.get_node('CollisionShape2D').queue_free()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	death.visible = true
	Engine.time_scale = 1.0
	get_tree().paused = true
	pass # Replace with function body.
