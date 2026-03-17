extends Node2D
@onready var setting: CanvasLayer = %Setting

func alert(text):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	add_child(dialog)
	dialog.popup_centered()
	
# 暂停游戏
func _game_pause():
	get_tree().paused = true
	setting.visible = true
# 继续游戏
func _game_resume():
	get_tree().paused = false
	setting.visible = false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setting.visible = false
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("进入后台，暂停游戏")
		_game_pause()
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		print("回到前台，恢复游戏")
		_game_pause()
		


func _on_setting_pressed() -> void:
	_game_pause();
	pass # Replace with function body.
