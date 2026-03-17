extends Node2D
	
var _rn: RNInterface

@onready var game_manager: Node = %GameManager

func change_scene(path: String, params := {}) -> void:
	var tree := get_tree()
	#tree.paused = true

	tree.change_scene_to_file(path)
	if "init" in params:
		params.init.call()
	
	await tree.tree_changed

	#tree.paused = false
	
func _ready() -> void:
	_rn = get_node("RNInterface") as RNInterface
	
		
func _on_new_game_pressed() -> void:
	change_scene("res://scenes/game.tscn", {})


func _on_load_game_pressed() -> void:
	pass # Replace with function body.
	

func _on_exit_game_pressed() -> void:
	if _rn == null:
		return
	_rn.call_close_app()


func _on_website_pressed() -> void:
	if _rn == null:
		return
	_rn.call_open_browser("https://godotengine.org")
