extends KinematicBody2D

#params
var speed : float = 300
var gravity : float = 50
var jump : float = 15
var floor_collision_angle : float = 70
var step_down_max : float = 8
var step_up_max : float = 8
var step_up_delta : float = .1

#consts
var fca : float = deg2rad(floor_collision_angle) #store in radians

#state
var velocity : Vector2 = Vector2.ZERO
var falling : bool = true #triggers gravity, enabled on jump and when auto-step-down failed to find floor
var floor_angle : float = 0 #most recent floor collision angle

func _physics_process(delta):
	move(delta)

func move(delta):
	if falling:
		#step x
		var input = lr()
		var movement = input * speed * delta
		move_and_collide(movement)
		#step y
		velocity += Vector2.DOWN * gravity * delta
		var collision = move_and_collide(velocity)
		if collision:
			if is_floor_collision(collision):
				falling = false
				velocity = Vector2.ZERO
			else:
				velocity = velocity.slide(collision.normal)
				move_and_collide(collision.remainder.slide(collision.normal))
		velocity.x = 0 #eliminate horizontal momentum caused by sliding, after each move step
	else:
		#step x
		var input = lr()
		if input != Vector2.ZERO:
			#scale horizontal move speed based on most recent floor collision angle (to make actual speed constant)
			var movement = input * speed * delta * cos(floor_angle)
			var old_pos : Vector2 = position
			var collision = move_and_collide(movement)
			if collision: #auto-step-up
				if is_floor_collision(collision): #if collided into a wall, do nothing
					old_pos = position
					var remainder : Vector2 = collision.remainder
					var step_up : float = 0
					while true:
						collision = move_and_collide(Vector2.UP * step_up_delta) #step-up
						if collision: #collided into ceiling
							step_up += step_up_delta - collision.remainder.length()
							move_and_collide(remainder) #one last push
							break
						step_up += step_up_delta
						collision = move_and_collide(remainder) #step-across
						if collision:
							if is_floor_collision(collision):
								remainder = collision.remainder
							else: #collided into a wall
								break
						else: #completed movement
							break
					if step_up > step_up_max: #undo movement if we ascended more than step_up_max this frame
						position = old_pos
				else: #collided into a wall or ceiling
					falling = true #avoid getting stuck on ceilings
			else: #auto-step-down
				collision = move_and_collide(Vector2.DOWN * step_down_max, true, true, true)
				if collision and is_floor_collision(collision):
					move_and_collide(Vector2.DOWN * step_down_max)
				else:
					falling = true
		#step y
		if !falling:
			if Input.is_action_just_pressed("interact"):
				falling = true
				velocity.y = -jump
	
func is_floor_collision(collision) -> bool:
	var angle : float = collision.get_angle()
	if angle <= fca:
		floor_angle = angle
		return true
	else:
		return false
	
func lr() -> Vector2:
	var input : Vector2 = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	return input

#FUNCTIONS FOR DEBUGGING
func debug_move_collide(delta):
	var input = lrud()
	var movement = input*speed*delta
	var collision = move_and_collide(movement)
	if collision:
		pass

func debug_move_through(delta):
	var input = lrud()
	var movement = input*speed*delta
	position += movement
	pass

func lrud() -> Vector2:
	var input : Vector2 = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	return input.normalized()

