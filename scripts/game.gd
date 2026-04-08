extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cur_map = GameManager.get_current_map_data()
	GameManager.change_map(cur_map.name, {
		"type": "init",
	})
	GameManager.connect("state_changed", func (state):
		# 避免后台回调触发后重复调用 pause()，导致 set_state->emit 递归。
		if state.isBackground == true and state.status != "setting":
			GameManager.pause()
	)


func _on_setting_pressed() -> void:
	GameManager.pause()
	pass # Replace with function body.
	
