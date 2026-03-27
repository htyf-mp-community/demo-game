extends Node
signal state_changed

var state = {
	# 当前游戏状态：'running' | 'paused' | 'gameover' | 'title' | 'setting' | 'death'
	# 默认是标题界面
	"status": 'title',
	# title | game
	"scene": "title",
	"isBackground": false,
	"score": 0,
	"isDeath": false,
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
	emit_signal("state_changed", new_state)
	

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
						s.isBackground = false
						return s
				)
			
	)


func add_point(): 
	self.set_state(
		func(s):
			s.score += 1	
			print(s.score)
			return s
	)
	

func change_scene(path: String, params := {}) -> void:
	Engine.time_scale = 1.0
	var tree := get_tree()
	var animation_player := Transition.find_child("AnimationPlayer") as AnimationPlayer
	
	tree.paused = false

	# 先淡出再切场景。不要在淡出前暂停树，否则动画可能不更新导致卡住。
	if animation_player:
		animation_player.play("fade_out")
		await animation_player.animation_finished
	
	tree.change_scene_to_file(path)
	
	if animation_player:
			animation_player.play("fade_in")
			await animation_player.animation_finished
	

	if "init" in params:
		params.init.call()
	
	
func run_game():
	if state.status == "game":
		return
	self.set_state(
		func(s):
			s.isDeath = false
			s.status = 'game'	
			return s
	)
	change_scene("res://scenes/game.tscn")

func exit_game() -> void:
	if state.status == "title":
		return
	self.set_state(
		func(s):
			s.isDeath = false
			s.status = 'title'	
			return s
	)
	change_scene("res://scenes/title_screen.tscn")
	
func death():
	if state.status == "death":
		return
	self.set_state(
		func(s):
			s.isDeath = true
			s.status = 'death'	
			return s
	)
	Engine.time_scale = 1.0
	#get_tree().paused = true

func pause():
	if state.status == "setting":
		return
	self.set_state(
		func(s):
			s.status = 'setting'	
			return s
	)
	get_tree().paused = true

func resume():
	if state.status == "game":
		return
	self.set_state(
		func(s):
			s.isDeath = false
			s.status = 'game'	
			return s
	)
	Engine.time_scale = 1.0
	get_tree().paused = false

	
func restart(): 
	if state.status == "game":
		return
	self.set_state(
		func(s):
			s.isDeath = false
			s.status = 'game'	
			return s
	)
	var tree := get_tree()
	if tree:
		# 先取消暂停，避免重载后仍保持 paused 状态。
		tree.paused = false
		tree.reload_current_scene()
