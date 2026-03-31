extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var camera_2d: Camera2D = $Camera2D

var config = null

func init(options = {}):
	config = options
	self.global_position = Vector2(options.get("x", 0), options.get("y", 0))
	

func _ready() -> void:
	# 根据 TileMap 已使用区域计算相机可移动边界，防止镜头超出地图。
	if config != null:
		self.global_position = Vector2(config.get("x", 0), config.get("y", 0))
		camera_2d.limit_top = config.get('limit_top', -10000000)
		camera_2d.limit_right = config.get('limit_right', 10000000)
		camera_2d.limit_bottom = config.get('limit_bottom', 10000000)
		camera_2d.limit_left = config.get('limit_left', -10000000)
		print("xxxxx", config)
		# 重置相机平滑
		camera_2d.reset_smoothing()
		
		var dir = config.get("dir", "right")
		if animated_sprite_2d != null:
			if dir == "right":
				animated_sprite_2d.flip_h = false
			elif dir == "left":
				animated_sprite_2d.flip_h = true
	
	GameManager.connect("state_changed", 
		func (s): 
			if s.isDeath == true:
				animated_sprite_2d.play("death")
				Input.vibrate_handheld()
	)

func _physics_process(delta: float) -> void:
	if GameManager.state.isDeath == false:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		
		if direction	 > 0:
			animated_sprite_2d.flip_h = false
		elif direction <	0:
			animated_sprite_2d.flip_h = true;
			
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play('idle')
			else :
				animated_sprite_2d.play("run")
		else :
			animated_sprite_2d.play('jump')
			
		if direction:
			velocity.x = direction * SPEED
			
			
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d != null:
		var animation = animated_sprite_2d.animation
		var frame = animated_sprite_2d.frame
		if  frame == 1:
			if animation == "jump":
				jump_sound.play()
			if animation == 'death':
				death_sound.play()
		
