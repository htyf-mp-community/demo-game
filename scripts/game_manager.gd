extends Node
@onready var score_label: Label = %ScoreLabel

var score = 0
var data = null

func _ready() -> void:
	var msg = 	await  HtyfSdk.call_rn("getMenuButtonBoundingClientRect", {})
	if msg == null:
		data = msg

func add_point(): 
	score += 1
	score_label.text = '$ ' + str(score)
	print(score)
	
func get_menu_button_bounding_client_rect() -> void:
	var msg = 	await  HtyfSdk.call_rn("getMenuButtonBoundingClientRect", {})
	if msg == null:
		data = msg

func change_scene(path: String, params := {}) -> void:
	var tree := get_tree()
	#tree.paused = true

	tree.change_scene_to_file(path)
	if "init" in params:
		params.init.call()
	
	await tree.tree_changed
	tree.paused = false
	
func _exit_change_scene() -> void:
	change_scene("res://scenes/title_screen.tscn")
