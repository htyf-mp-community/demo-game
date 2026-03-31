extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var back_door: Area2D = $BackDoor

var config = null

func init(options = {}):
	config = options
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if config != null:
		back_door.init(config.get('back', {}))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_camera_2d_limit():
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
