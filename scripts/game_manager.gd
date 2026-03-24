extends Node
@onready var score_label: Label = %ScoreLabel
signal state_changed

var state = {
	# 当前游戏状态：'running' | 'paused' | 'gameover' | 'title' | 'setting' | 'death'
	# 默认是标题界面
	"status": 'title',
	# title | game
	"scene": "title",
	"isBackground": false,
	"score": 0,
	"menuBtonBoundingClientRect": {
		"top": 0, 
		"right": 0, 
		"bottom": 0, 
		"left": 0, 
		"width": 0, 
		"height": 0 
	}
}

# ===== 核心 set 方法 =====
func set_state(updater: Callable):
	var new_state = updater.call(state.duplicate(true))
	state = new_state
	emit_signal("state_changed")
	

func _ready() -> void:
	HtyfSdk.call_get_menu_button_bounding_client_rect(
		func (result): 
			self.set_state(
				func(s): 
					s.menuBtonBoundingClientRect = result
					return s
			)
	)
	HtyfSdk.set_host_lifecycle_callback(
		func (what: int): 
			if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
				HtyfSdk.log("进入后台，暂停游戏")
				self.set_state(
					func(s):
						s.isBackground = true
						return s
				)
			if what == NOTIFICATION_APPLICATION_FOCUS_IN:
				HtyfSdk.log("回到前台，恢复游戏")
				self.set_state(
					func(s):
						s.isBackground = true
						return s
				)
			
	)


func add_point(): 
	self.set_state(
		func(s):
			s.score += 1	
			print(s.score)
			score_label.text = '$ ' + str(s.score)
			return s
	)
	

func change_scene(path: String, params := {}) -> void:
	Engine.time_scale = 1.0
	var tree := get_tree()
	tree.paused = true

	tree.change_scene_to_file(path)
	if "init" in params:
		params.init.call()
	
	await tree.tree_changed
	tree.paused = false
	
func run_game():
	change_scene("res://scenes/game.tscn")

func exit_game() -> void:
	change_scene("res://scenes/title_screen.tscn")
	
