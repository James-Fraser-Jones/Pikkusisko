extends Camera2D

export var path_to_player : NodePath
export var path_to_camera_path : NodePath
export var smoothing : bool = true
export var camera_speed : float = 8

onready var player = get_node(path_to_player)
onready var camera_path : Path2D = get_node_or_null(path_to_camera_path)

func _physics_process(delta):
	var new_position : Vector2
	if is_instance_valid(camera_path): # if camera_path has been provided
		var curve : Curve2D = camera_path.curve
		new_position = curve.get_closest_point(player.global_position)
	else: # otherwise, camera_path is null
		new_position = player.global_position
		
	
	if smoothing:
		global_position = lerp(global_position, new_position, camera_speed*delta)
	else:
		global_position = global_position.move_toward(new_position,camera_speed*delta)
		
