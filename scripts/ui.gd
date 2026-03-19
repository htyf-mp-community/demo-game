extends CanvasLayer

@onready var setting: Button = $Setting

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HtyfSdk.call_get_menu_button_bounding_client_rect(
		func (result): 
			var rect = result
			var size = setting.size
			# 根据小程序胶囊按钮矩形坐标定位设置按钮。
			setting.offset_top = rect.get("top", 0)
			# 设置按钮的左边与胶囊按钮的左边对齐。
			setting.offset_right = -(rect.get("right", 0) + rect.get("width", 0))
			if setting.offset_top == 0:
				setting.offset_top = 20
			if setting.offset_right == 0:
				setting.offset_right = -20
			# HtyfSdk.call_show_modal("rect", JSON.stringify(rect))
			# HtyfSdk.call_show_modal("offset_top", JSON.stringify(setting.offset_top))
			print("setting.size.x: "+ str(setting.size.x))
			print("setting.offset_top: "+ str(setting.offset_top))
			print("setting.offset_right: "+ str(setting.offset_right))
	)
