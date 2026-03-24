extends CanvasLayer

func _ready() -> void:
	self.visible = false
	GameManager.connect("state_changed", 
		func(s):
			if s.status == "setting":
				self.visible = true
	)

func _on_start_pressed() -> void:
	print("继续")
	self.visible = false
	GameManager.resume()


func _on_button_pressed() -> void:
	GameManager.exit_game()
	print("退出")
