extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	GameManager.connect("state_changed", func (state):
		if state.status == 'death':
			self.visible = true
		elif self.visible == true:
			self.visible = false
	)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed() -> void:
	GameManager.restart()


func _on_exit_pressed() -> void:
	GameManager.exit_game()
	pass # Replace with function body.


func _on_ad_pressed() -> void:
	HtyfSdk.call_show_interstitial_ad()
	pass # Replace with function body.
