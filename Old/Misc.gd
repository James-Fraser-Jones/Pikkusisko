extends Node

#Miscellaneous chunks of old code which might be useful for future reference

#func screen_ray(x):
#	var height : int = ProjectSettings.get_setting("display/window/size/height")
#	var camera : Camera2D = $"../Camera2D"
#	var top : int = camera.position.y - height/2 - 100
#	var bottom : int = camera.position.y + height/2 + 100
#	var space_state = get_world_2d().direct_space_state
#	var result = space_state.intersect_ray(Vector2(x, top), Vector2(x, bottom))
#	if result:
#		print("ID: ", result.collider_id, ", Index: ", result.shape)
