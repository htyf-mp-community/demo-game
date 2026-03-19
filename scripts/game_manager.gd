extends Node
@onready var score_label: Label = %ScoreLabel

var score = 0

# 红糖云小程序中的胶囊菜单定位
var menuBtonBoundingClientRect := {
	"top": 0, 
	"right": 0, 
	"bottom": 0, 
	"left": 0, 
	"width": 0, 
	"height": 0 
}

func _ready() -> void:
	HtyfSdk.call_get_menu_button_bounding_client_rect(
		func (result): 
			#HtyfSdk.call_show_modal("test", JSON.stringify(result))
			menuBtonBoundingClientRect = result
	)


func add_point(): 
	score += 1
	score_label.text = '$ ' + str(score)
	print(score)

func change_scene(path: String, params := {}) -> void:
	Engine.time_scale = 1.0
	var tree := get_tree()
	tree.paused = true

	tree.change_scene_to_file(path)
	if "init" in params:
		params.init.call()
	
	await tree.tree_changed
	tree.paused = false
	
func _exit_change_scene() -> void:
	change_scene("res://scenes/title_screen.tscn")
