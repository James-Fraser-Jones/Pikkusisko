extends KinematicBody2D

#params
var speed : float = 300
var gravity : float = 50
var jump : float = 15
var foot_collision_angle : float = 70 
var step_down_max : float = 5
var step_up_delta : float = .2

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
			var old_x : float = position.x
			var movement = input * speed * delta
			var collision = move_and_collide(movement)
			if collision and is_foot_collision(collision): #auto-step-up
				position.x += collision.remainder.x #consistent horizontal speed, regardless of slope
				var info = {"collider": collision.collider_id, "shape": collision.collider_shape_index}
				var new_info
				while true:
					position.y -= step_up_delta
					new_info = colliding_with()
					if new_info:
						if info.collider != new_info.collider or info.shape != new_info.shape: #collided into ceiling
							position.x = old_x #undo movement entirely
							break
					else: #no-longer colliding
						break
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
