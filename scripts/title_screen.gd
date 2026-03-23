extends Node2D
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	HtyfSdk.log("init")
		
func _on_new_game_pressed() -> void:
	HtyfSdk.log("开始新游戏")
	GameManager.change_scene("res://scenes/game.tscn", {})


func _on_load_game_pressed() -> void:
	pass # Replace with function body.
	

func _on_exit_game_pressed() -> void:
	HtyfSdk.log("退出")
	HtyfSdk.call_close_app()


func _on_website_pressed() -> void:
	if HtyfSdk == null:
		return
	HtyfSdk.call_open_browser("https://godotengine.org")
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		HtyfSdk.log("进入后台，暂停游戏")
		get_tree().paused = true
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		HtyfSdk.log("回到前台，恢复游戏")
		get_tree().paused = false
