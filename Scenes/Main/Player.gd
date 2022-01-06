extends KinematicBody2D

#params
var speed : float = 300
var gravity : float = 50
var jump : float = 15
var foot_collision_angle : float = 70
var step_down_max : float = 8
var step_up_max : float = 8
var step_up_delta : float = .1

#state
var velocity : Vector2 = Vector2.ZERO
var falling : bool = true #triggers gravity, enabled on jump and when auto-step-down failed to find floor

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
			if is_foot_collision(collision):
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
			var movement = input * speed * delta
			var collision = move_and_collide(movement)
			if collision: #auto-step-up
				if is_foot_collision(collision): #if collided into a wall, do nothing
					var old_pos : Vector2 = position
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
							remainder = collision.remainder
						else: #completed movement
							break
					if step_up > step_up_max: #undo movement if we ascended more than step_up_max this frame
						position = old_pos	
			else: #auto-step-down
				collision = move_and_collide(Vector2.DOWN * step_down_max, true, true, true)
				if collision and is_foot_collision(collision):
					move_and_collide(Vector2.DOWN * step_down_max)
				else:
					falling = true
		#step y
		if !falling:
			if Input.is_action_just_pressed("up"):
				falling = true
				velocity.y = -jump
	
func is_foot_collision(collision) -> bool:
	var deg_angle : float = rad2deg(collision.get_angle())
	return deg_angle <= foot_collision_angle
	
func colliding_with() -> Dictionary:
	var collision = move_and_collide(Vector2.ZERO, true, true, true)
	if collision:
		return {"collider": collision.collider_id, "shape": collision.collider_shape_index}
	return {}
	
func lr() -> Vector2:
	var input : Vector2 = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	return input

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
