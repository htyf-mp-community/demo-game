extends Area2D

var target_map = "maps_2"


func init(c):
	target_map = c

func _ready() -> void:
	print(self.global_position)

func _on_body_entered(body: Node2D) -> void:
	var next_map = GameManager.get_next_map_data()
	var cur_map = GameManager.get_current_map_data()
	print("next_map", next_map, cur_map)
	GameManager.change_map(next_map.get('name', ''), {
		"exit_point": {
			"x": cur_map.get("spawn", {}).get('next', {}).get('x', 0),
			"y": cur_map.get("spawn", {}).get('next', {}).get('y', 0),
			"dir": cur_map.get("spawn", {}).get('next', {}).get('dir', 'right')
		}
	})
