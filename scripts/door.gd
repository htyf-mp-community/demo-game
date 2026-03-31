extends Area2D

var target_map = "maps_2"

func init(c):
	target_map = c


func _on_body_entered(body: Node2D) -> void:
	print("xxxxxxx")
	GameManager.change_map(target_map)
