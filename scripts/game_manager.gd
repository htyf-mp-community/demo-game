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
	},
	"current_map": "maps_1",
	"maps_config": {},
	"maps_hostory": []
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
	self.set_state(
		func(s):
			s.maps_config = data	
			return s
	)
	return json.data

func add_point(): 
	self.set_state(
		func(s):
			s.score += 1	
			print(s.score)
			return s
	)

# 切换场景
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
	self.set_maps_hostory([])
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
		var cur_map = self.get_current_map_data()
		self.change_map(cur_map.get("name"))
		#tree.reload_current_scene()
# 设置地图历史
func set_maps_hostory(hostory = []):
	self.set_state(
		func(s):
			s.maps_hostory = hostory
			return s
	)
# 删除地图历史中的单条数据
func delete_maps_hostory_item(map_name: String):
	self.set_state(
		func(s):
			var hostory = s.get("maps_hostory", [])
			for i in range(hostory.size()):
				var item = hostory[i]
				if typeof(item) == TYPE_DICTIONARY and item.get("map_name", "") == map_name:
					hostory.remove_at(i)
					break
			s.maps_hostory = hostory
			return s
	)
# 按 map_name 修改地图历史中的单条数据（增量合并）
func update_maps_hostory_item(map_name: String, patch := {}):
	self.set_state(
		func(s):
			var hostory = s.get("maps_hostory", [])
			var target_index := -1
			for i in range(hostory.size()):
				var item = hostory[i]
				if typeof(item) == TYPE_DICTIONARY and item.get("map_name", "") == map_name:
					target_index = i
					break
			if target_index == -1:
				var new_item = {"map_name": map_name}
				if typeof(patch) == TYPE_DICTIONARY:
					new_item = new_item.merged(patch, true)
				else:
					new_item["data"] = patch
				hostory.append(new_item)
				s.maps_hostory = hostory
				return s
			var old_item = hostory[target_index]
			if typeof(old_item) != TYPE_DICTIONARY or typeof(patch) != TYPE_DICTIONARY:
				hostory[target_index] = patch
			else:
				hostory[target_index] = old_item.merged(patch, true)
			s.maps_hostory = hostory
			return s
	)
# 获取当前地图数据
func get_current_map_data():
	var hostory = state.get("maps_hostory", [])
	var maps_info: Dictionary = self.load_map().get("maps_info", {})
	if hostory.is_empty():
		return maps_info.get(self.load_map().get("maps_sort", [])[0], {})
	# 末尾即当前地图
	return maps_info.get(hostory[hostory.size() - 1].get("map_name", ""), {})
# 获取前一个地图数据
func get_prev_map_data():
	var hostory = state.get("maps_hostory", [])
	var maps_info: Dictionary = self.load_map().get("maps_info", {})
	print("hostory", hostory, hostory.size())
	if hostory.size() < 2:
		return {}
	# 倒数第二项即上一个地图
	return maps_info.get(hostory[hostory.size() - 2].get("map_name", ""), {})
# 获取下一个地图数据
func get_next_map_data():
	var maps: Dictionary = self.load_map()
	var current_map = self.get_current_map_data()
	var next_map_index = maps.get("maps_sort", []).find(current_map.get("name", "")) + 1
	print("current_map", current_map, next_map_index)
	if next_map_index >= maps.get("maps_sort", []).size():
		return {}
	var next_map = maps.get("maps_sort", [])[next_map_index]
	return maps.get("maps_info", {}).get(next_map, {})

# 切换地图
func change_map(map_name: String = "maps_1", options: Dictionary = {}) -> void:
	if options.get("type", "") != "init":
		var tree := get_tree()
		var animation_player := Transition.find_child("AnimationPlayer") as AnimationPlayer
	
		tree.paused = false

		# 先淡出再切场景。不要在淡出前暂停树，否则动画可能不更新导致卡住。
		if animation_player:
			animation_player.play("fade_out")
			await animation_player.animation_finished
	

	var map_root := get_tree().current_scene.get_node("MapRoot")
	# 删除旧地图
	if map_root.get_child_count() > 0:
		map_root.get_child(0).queue_free()
	
	# 1) 读取目标地图配置，并准备默认出生点
	var maps: Dictionary = load_map()
	var next_map: Dictionary = maps.get("maps_info", {}).get(map_name, {})
	var tscn: String = next_map.get("file", "")
	var spawn: Dictionary = next_map.get("spawn", {})
	var spawn_position: Dictionary = spawn.get("init", {
		"x": 0,
		"y": 0,
		"dir": "right"
	})
	var spawn_next_position: Dictionary = spawn.get("next", spawn_position)
	var player_position: Dictionary = spawn_position
	var is_back: bool = options.get("type", "") == "back"

	# 2) 先把新地图实例化并挂载，确保后续可以读取相机边界
	# 加载新地图
	var new_map = load(tscn).instantiate()
	new_map.init()
	map_root.add_child(new_map)

	# 3) 维护地图历史，并确定玩家最终出生点
	if is_back:
		# back: 回到上一个地图时，出生在“上一个地图记录的退出点”
		var cur_map_data: Dictionary = self.get_current_map_data()
		var prev_map_data: Dictionary = self.get_prev_map_data()
		player_position = prev_map_data.get("exit_point", spawn_next_position)
		
		# 回退后，当前地图记录应从历史中移除
		self.delete_maps_hostory_item(cur_map_data.get("name", ""))
	else:
		# forward: 记录当前地图的退出点，供之后 back 使用
		var exit_point = options.get("exit_point", null)
		if exit_point != null and exit_point.size() > 0:
			print("exit_point", exit_point)
			var current_map_data: Dictionary = self.get_current_map_data()
			self.update_maps_hostory_item(current_map_data.get("name", ""), {
				"exit_point": {
					"x": exit_point.get('x', 0),
					"y": exit_point.get('y', 0),
					"dir": "right"
				}
			})

		# 记录目标地图入口点；不存在则会自动新增历史项
		if map_name != "":
			self.update_maps_hostory_item(map_name, {
				"enter_point": {
					"x": player_position.x,
					"y": player_position.y,
					"dir": "right"
				}
			})
	
	print("player_position", self.state.maps_hostory)

	var player = load("res://scenes/Player.tscn").instantiate()
	
	# 4) 使用地图相机边界初始化玩家
	var limit: Dictionary = new_map.get_camera_2d_limit()
	
	player.init({
		"x": player_position.x,
		"y": player_position.y,
		"dir": player_position.dir,
		"limit_top": limit.get("limit_top", -10000000),
		"limit_right": limit.get("limit_right", 10000000),
		"limit_bottom": limit.get("limit_bottom", 10000000),
		"limit_left": limit.get("limit_left", -10000000)
	})

	# 最后再把玩家加到地图，避免初始化中引用未就绪节点
	new_map.add_child(player) 

	if options.get("type", "") != "init":
		var tree := get_tree()
		var animation_player := Transition.find_child("AnimationPlayer") as AnimationPlayer
	
		tree.paused = false

		# 先淡出再切场景。不要在淡出前暂停树，否则动画可能不更新导致卡住。
		if animation_player:
			animation_player.play("fade_in")
			await animation_player.animation_finished
	
	
	
	
	

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
