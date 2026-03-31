extends Node
signal state_changed

const SAVE_FILE_PATH = "user://save_game.json"

const MAPS_CONFIG_FILE_PATH = "res://scenes/maps/index.json"

var state = {
	"scene_path": "",
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
	load_map()
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

func load_map():
	print("load map")
	var file = FileAccess.open(MAPS_CONFIG_FILE_PATH, FileAccess.READ)
	if not file:
		print("Error loading game: file is null")
		return
	var json = JSON.new()
	var data = json.parse(file.get_as_text())
	return json.data

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
	self.save_game()
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
		
func change_map(map_name = "maps_1", options = {}):
	var map_root := get_tree().current_scene.get_node("MapRoot")
	# 删除旧地图
	if map_root.get_child_count() > 0:
		map_root.get_child(0).queue_free()
	var maps = load_map()
	var cur_map = maps.get(map_name, {})
	var tscn = cur_map.get("file", "")
	var spawn = cur_map.get("spawn", {})
	var spawn_position = spawn.get("default", {
		"x": 0,
		"y": 0,
		"dir": "right"
	})
	# 加载新地图
	var new_map = load(tscn).instantiate()
	new_map.init({
		"back": {
			"target": "maps_1",
			"x": 600,
			"y": 234,
			"dir": "left"
		}
	})
	map_root.add_child(new_map)
	
	var player = load("res://scenes/Player.tscn").instantiate()
	
	# 加载地图完成后获取相机limit
	var limit = new_map.get_camera_2d_limit()
	var back = options.get("back")
	print("xxxxssss", back)
	if back != null:
		player.init({
			"x": back.x,
			"y": back.y,
			"dir": back.dir,
			"limit_top": limit.get('limit_top', -10000000),
			"limit_right": limit.get('limit_right', 10000000),
			"limit_bottom": limit.get('limit_bottom', 10000000),
			"limit_left": limit.get('limit_left', -10000000)
		})
	else:
		player.init({
			"x": spawn_position.x,
			"y": spawn_position.y,
			"dir": spawn_position.dir,
			"limit_top": limit.get('limit_top', -10000000),
			"limit_right": limit.get('limit_right', 10000000),
			"limit_bottom": limit.get('limit_bottom', 10000000),
			"limit_left": limit.get('limit_left', -10000000)
		})
	
	new_map.add_child(player) 
	
	
	
	
	
	

func save_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		print("Error saving game: file is null")
		return
	var scene := get_tree().current_scene
	var scene_name = scene.scene_file_path.get_file().get_basename()
	state.scene_path = scene.scene_file_path
	file.store_string(JSON.stringify(state))

func load_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		print("Error loading game: file is null")
		return
	var json = JSON.new()
	var data = json.parse(file.get_as_text())
	print(json.data)
	
	if data:
		state = json.data
		if state.scene_path != "":
			self.change_scene(state.scene_path)
		#self.change_scene("")
	else:
		print("Error loading game: ", data.error_string)
