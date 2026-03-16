extends Node

var score = 0
@onready var score_label: Label = %ScoreLabel

func add_point(): 
	score += 1
	score_label.text = '$ ' + str(score)
	print(score)


func change_scene(path: String, params := {}) -> void:
	var duration := params.get("duration", 0.2) as float
	
	var tree := get_tree()
	tree.paused = true
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.finished
	
	
	tree.change_scene_to_file(path)
	if "init" in params:
		params.init.call()
	
	#await tree.process_frame  # 4.2 以前
	await tree.tree_changed  # 4.2 开始
	
	
	tree.paused = false
	
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
