extends Camera2D

enum MODE {
	FREE,	# no paths to follow and no areas to stay in
	
	PATH,	# follows the Curve2D that's defined in the specified Path2D ndoe
			# use "path_to_camera_path"
			# utilizes Curve2D's get_closest_point() method
	
	AREA,	# stays in area that's defined in the specified Navigation2D node
			# use "path_to_camera_area"
			# utilizes Navigation2D's get_closest_point() method
			
	POINT	# looks at a specific point defined in the camera_point variable
}


export(MODE) var mode : int = MODE.PATH
export var path_to_player : NodePath # required
export var path_to_camera_path : NodePath # only required for path mode
export var path_to_camera_area : NodePath # only required for area mode
export var camera_point : Vector2
export var smoothing : bool = true
export var camera_speed : float = 8

onready var player = get_node(path_to_player)
onready var camera_path : Path2D = get_node_or_null(path_to_camera_path)
onready var camera_area : Navigation2D = get_node_or_null(path_to_camera_area)

func _physics_process(delta):
	var new_position : Vector2
	
	if mode == MODE.PATH and is_instance_valid(camera_path):
		new_position = camera_path.curve.get_closest_point(player.global_position)
	elif mode == MODE.AREA and is_instance_valid(camera_area):
		new_position = camera_area.get_closest_point(player.global_position)
	elif mode == MODE.POINT:
		new_position = camera_point
	else:
		new_position = player.global_position
		
	
	if smoothing:
		global_position = lerp(global_position, new_position, camera_speed*delta)
	else:
		global_position = global_position.move_toward(new_position,camera_speed*delta)
		
