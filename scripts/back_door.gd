extends Area2D


func _on_body_entered(body: Node2D) -> void:
	var exitPositon = self.global_position
	var prev_map_data = GameManager.get_prev_map_data()
	print("prev_map_data", prev_map_data)
	GameManager.change_map(prev_map_data.get('name'), {
		"type": "back",
	})
