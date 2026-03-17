extends CanvasLayer
@onready var settiing: CanvasLayer = $"."

func _on_start_pressed() -> void:
	print("继续")
	settiing.visible = false
	get_tree().paused = false
