extends Area2D

@onready var death: CanvasLayer = %Death
@onready var hurt_soud: AudioStreamPlayer2D = $hurt_soud

func _on_body_entered(body: Node2D) -> void:
	GameManager.death()
	
	#body.get_node('CollisionShape2D').queue_free()
	pass # Replace with function body.
