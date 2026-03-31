extends Area2D

var target_map = {
	"target": "maps_1",
	"x": 600,
	"y": 234,
	"dir": "left"
}

func init(c):
	target_map = c


func _on_body_entered(body: Node2D) -> void:
	print("xxxxxxx")
	
	GameManager.change_map(target_map.get('target'), {
		"back": target_map
	})
