extends Node2D

func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	if Input.is_action_pressed("restart"):
		var scene = get_tree().get_current_scene()
		get_tree().change_scene(scene.get_filename())
