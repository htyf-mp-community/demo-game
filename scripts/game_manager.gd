extends Node
@onready var score_label: Label = %ScoreLabel
@onready var rn_interface: RNInterface = %RNInterface

var score = 0
var data = null

func _ready() -> void:
	var msg = 	await  rn_interface.call_rn("getMenuButtonBoundingClientRect", {})
	if msg == null:
		data = msg

func add_point(): 
	score += 1
	score_label.text = '$ ' + str(score)
	print(score)
	
func get_menu_button_bounding_client_rect() -> void:
	var msg = 	await  rn_interface.call_rn("getMenuButtonBoundingClientRect", {})
	if msg == null:
		data = msg
