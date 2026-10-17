extends CharacterBody3D

# Prędkość gracza 
@export var speed = 2

# Przyspieszenie grawitacyjne
@export var fall_acceleration = 75

# Wektor (x,y,z) przechowujacy speed i direction
var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# Kierunek
	var direction = Vector3.ZERO
	
	# Wykrywanie nacisniecia przycisku
	if Input.is_action_pressed("move_back"):
		direction.x += 1
		print("back")
	if Input.is_action_pressed("move_forward"):
		direction.x -= 1
		print("forward")
	if Input.is_action_pressed("move_left"):
		direction.z += 1
		print("left")
	if Input.is_action_pressed("move_right"):
		direction.z -= 1
		print("right")
		
	if direction != Vector3.ZERO:
		direction = direction.normalized() # Gracz nie bedzie przyspieszał idąc po przekatnej
		direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
	
	# Obliczanie predkosci gracza
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed	
	
	# Grawitacja
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	# Poruszanie graczem
	velocity = target_velocity
	move_and_slide()
