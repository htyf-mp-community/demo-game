extends Area2D


func _on_body_entered(body: Node2D) -> void:
	var exitPositon = self.global_position
	var prev_map_data = GameManager.get_prev_map_data()
	
	GameManager.change_map(prev_map_data.get('map_name'), {
		"type": "back",
	})
