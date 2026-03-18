extends CanvasLayer
@onready var settiing: CanvasLayer = $"."

func _on_start_pressed() -> void:
	print("继续")
	settiing.visible = false
	get_tree().paused = false


func _on_button_pressed() -> void:
	GameManager._exit_change_scene()
	print("退出")
