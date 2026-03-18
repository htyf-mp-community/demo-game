extends Node2D

func change_scene(path: String, params := {}) -> void:
	var tree := get_tree()
	#tree.paused = true

	tree.change_scene_to_file(path)
	if "init" in params:
		params.init.call()
	
	await tree.tree_changed

	#tree.paused = false
	
func _ready() -> void:
	pass
	
		
func _on_new_game_pressed() -> void:
	change_scene("res://scenes/game.tscn", {})


func _on_load_game_pressed() -> void:
	pass # Replace with function body.
	

func _on_exit_game_pressed() -> void:
	print("退出")
	HtyfSdk.call_close_app()


func _on_website_pressed() -> void:
	if HtyfSdk == null:
		return
	HtyfSdk.call_open_browser("https://godotengine.org")
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("进入后台，暂停游戏")
		get_tree().paused = true
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		print("回到前台，恢复游戏")
		get_tree().paused = false
