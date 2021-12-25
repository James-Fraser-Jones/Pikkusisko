extends KinematicBody2D

#to implement auto-step-up we just need a way to fire a raycast at the specifc convext collision shape
#which the foot collided with, ignoring all other colliders and all other collision shapes in this collider
#but don't allow auto-step-up in the case where the player is still colliding with something when placed at the correct position
#we step x before y, but in practice the only time the player will ever have vertical movement is due to gravity so
#we could just have seperate movement mechanics during "falling"
#falling ends when a foot collision occours, at which point gravity is disabled again
#also we should add logic to make climbing slopes slower depending on incline, based on pythag to keep roughly constant speed
#for some reason bashing player's head allows them to "slide" using the debug movement (bug?)
#also works for moving downwards but only on particularly steep inclines, this shouldn't matter too much anyway

var speed : float = 400
var gravity : float = 100
var foot_collision_angle : float = 70 #don't auto-step-down onto a non-foot-colliding surface!
var max_step_up : float = 5
var max_step_down : float = 5

var falling : bool = true #triggers gravity, enabled on jump and when auto-step-down failed

func _physics_process(delta):
	debug_move(delta)

func debug_move(delta):
	var input: Vector2 = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	var movement: Vector2 = input.normalized()*speed*delta
	var collision = move_and_collide(movement)
	if collision:
		var angle = rad2deg(abs(collision.normal.angle_to(Vector2.UP)))
		var foot_collision : bool = angle <= foot_collision_angle 
		print("ID: ", collision.collider_id, ", Index: ", collision.collider_shape_index, ", Angle: ", angle, ", Foot: ", foot_collision)
