extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed() -> void:
	var tree := get_tree()
	if tree:
		# 先取消暂停，避免重载后仍保持 paused 状态。
		tree.paused = false
		tree.reload_current_scene()


func _on_exit_pressed() -> void:
	GameManager._exit_change_scene()
	pass # Replace with function body.
