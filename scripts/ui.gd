extends CanvasLayer
@onready var game_manager: Node = %GameManager

@onready var setting: Button = $Setting

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data = await game_manager.get_menu_button_bounding_client_rect()
	if data != null:
		setting.offset_right = 0
	pass # Replace with function body.
