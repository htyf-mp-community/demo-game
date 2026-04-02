extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var config = null

var is_ready = false

func init(options = {}):
	config = options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_ready = true

# 获取当前地图的相机边界
func get_camera_2d_limit():
	if not is_ready:
		HtyfSdk.log("请先加载地图")
		return
	var used := tile_map_layer.get_used_rect()
	var tile_size := tile_map_layer.tile_set.tile_size
	
	# 根据 TileMap 已使用区域计算相机可移动边界，防止镜头超出地图。
	var limit_top = used.position.y * tile_size.y
	var limit_right = used.end.x * tile_size.x
	var limit_bottom = (used.end.y) * tile_size.y
	var limit_left = used.position.x * tile_size.x
	return {
		"limit_top": limit_top,
		"limit_right": limit_right,
		"limit_bottom": limit_bottom,
		"limit_left": limit_left,
	}

# 获取地图的起点位置
func get_start_position():
	if not is_ready:
		HtyfSdk.log("请先加载地图")
		return
	return {
		"x": 0,
		"y": 0,
		"dir": "right"
	}

# 获取地图的终点位置
func get_end_position():
	if not is_ready:
		HtyfSdk.log("请先加载地图")
		return
	return {
		"x": 0,
		"y": 0,
		"dir": "right"
	}

# 获取地图的相机边界、起点位置、终点位置
func get_map_info():
	if not is_ready:
		HtyfSdk.log("请先加载地图")
		return
	return {
		"camera_limit": self.get_camera_2d_limit(),
		"start_position": self.get_start_position(),
		"end_position": self.get_end_position(),
	}
