extends RigidBody3D

# Prędkość gracza 
@export var speed = 2

func _integrate_forces(state):
	# Kierunek
	var direction = Vector3.ZERO
	
	# Wykrywanie nacisniecia przycisku
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized() #Gracz nie bedzie przyspieszał idąc po przekatnej
		state.linear_velocity = Vector3(direction.x * speed, state.linear_velocity.y, direction.z * speed)
	else:
		state.linear_velocity = Vector3(0, state.linear_velocity.y, 0)	
		
	var current_velocity = state.linear_velocity
	
	current_velocity.x = direction.x * speed
	current_velocity.z = direction.z * speed
	
	state.linear_velocity = current_velocity
