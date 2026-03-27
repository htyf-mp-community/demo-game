extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var player: CharacterBody2D = $Player
@onready var camera_2d: Camera2D = $Player/Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var used := tile_map_layer.get_used_rect()
	var tile_size := tile_map_layer.tile_set.tile_size
	
	# 根据 TileMap 已使用区域计算相机可移动边界，防止镜头超出地图。
	camera_2d.limit_top = used.position.y * tile_size.y
	camera_2d.limit_right = used.end.x * tile_size.x
	camera_2d.limit_bottom = (used.end.y) * tile_size.y
	camera_2d.limit_left = used.position.x * tile_size.x
	print(camera_2d.limit_bottom)
	# 重置相机平滑
	camera_2d.reset_smoothing()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
