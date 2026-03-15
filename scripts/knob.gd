extends TouchScreenButton

# 拖动半径（基于当前相机可视区大小计算）
var drag_radius := 0.0

# 当前正在控制摇杆的手指编号（-1 表示没有手指在控制）
var finger_index := -1
# 记录：按下瞬间，手指在“摇杆本地坐标系”里的位置
var drag_start_finger_local: Vector2
# 记录：摇杆的静止位置（相对于父节点 / virtual_joypad 的本地坐标）
var rest_pos: Vector2


func _ready() -> void:
	# 初始静止位置：相对于 virtual_joypad（父节点）的本地坐标
	rest_pos = position

	# 以当前相机可视区尺寸来算一个拖动半径（这里用较短边的 10%）
	var vp_size := get_viewport().get_visible_rect().size
	drag_radius = min(vp_size.x, vp_size.y) * 1


func _input(event: InputEvent) -> void:
	# 触摸按下 / 抬起
	var st := event as InputEventScreenTouch
	if st:
		# 按下且当前没有手指在控制摇杆
		if st.pressed and finger_index == -1:
			# 把手指的屏幕坐标转换到“摇杆自己的本地坐标系”
			var local_pos := to_local(st.position)
			# 以贴图大小作为摇杆的本地矩形，用于命中检测
			var rect := Rect2(Vector2.ZERO, texture_normal.get_size())
			if rect.has_point(local_pos):
				# 命中摇杆，开始接管这个手指
				finger_index = st.index
				drag_start_finger_local = local_pos
		# 手指抬起且是当前控制摇杆的那个手指
		elif not st.pressed and st.index == finger_index:
			Input.action_release("ui_left")
			Input.action_release("ui_right")
			finger_index = -1
			# 松手时回到静止位置（相对于 virtual_joypad 的本地位置）
			position = rest_pos

	# 触摸拖动
	var sd := event as InputEventScreenDrag
	if sd and sd.index == finger_index:
		# 当前手指在摇杆本地坐标中的位置
		var cur_local := to_local(sd.position)
		# 与按下瞬间的位置做差，得到本地坐标系里的位移
		var delta_local := cur_local - drag_start_finger_local

		# 希望的摇杆位置（本地）：静止位置 + 手指本地位移
		var wish_pos := rest_pos + delta_local

		# 只允许在以 rest_pos 为圆心、半径 drag_radius 的圆内移动
		var movement := (wish_pos - rest_pos).limit_length(20.0)
		position = rest_pos + movement
		print('rest_pos:', rest_pos)
		print('movement:', movement)

		# movement.x 归一化到 [-1, 1]，用作左右输入强度
		var x := 0.0
		if drag_radius > 0.0:
			x = movement.x

		if x > 0.0:
			Input.action_release("ui_left")
			Input.action_press("ui_right", x)
		elif x < 0.0:
			Input.action_release("ui_right")
			Input.action_press("ui_left", -x)
