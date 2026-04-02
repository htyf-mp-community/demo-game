extends Area2D

var target_map = "maps_2"


func init(c):
	target_map = c

func _ready() -> void:
	print(self.global_position)

func _on_body_entered(body: Node2D) -> void:
	var exitPositon = self.global_position
	var body_size := Vector2.ZERO
	# 1) 优先拿碰撞体尺寸
	var collision := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision and collision.shape:
		if collision.shape is RectangleShape2D:
			body_size = (collision.shape as RectangleShape2D).size
		elif collision.shape is CircleShape2D:
			var r = (collision.shape as CircleShape2D).radius
			body_size = Vector2(r * 2.0, r * 2.0)
	# 2) 没拿到再尝试 Sprite2D 可见尺寸
	if body_size == Vector2.ZERO:
		var sprite := body.get_node_or_null("Sprite2D") as Sprite2D
		if sprite and sprite.texture:
			body_size = sprite.texture.get_size() * sprite.scale
	print("进入物体大小:", body_size)
	GameManager.change_map(target_map, {
		"exit_point": {
			"x": exitPositon.x - 20,
			"y": exitPositon.y
		}
	})
