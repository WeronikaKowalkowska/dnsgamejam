extends CharacterBody3D

@onready var sprite_3d: AnimatedSprite3D = $Sprite3D


# Prędkość gracza 
@export var speed = 4

# Przyspieszenie grawitacyjne
@export var fall_acceleration = 75

var is_moving: bool = false
var last_angle: int = 180

# Wektor (x,y,z) przechowujacy speed i direction
var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# Kierunek
	var direction = Vector3.ZERO
	
	# Wykrywanie nacisniecia przycisku
	if Input.is_action_pressed("move_back"):
		direction.x += 1
	if Input.is_action_pressed("move_forward"):
		direction.x -= 1
	if Input.is_action_pressed("move_left"):
		direction.z += 1
	if Input.is_action_pressed("move_right"):
		direction.z -= 1
	
	var vec_to_angle: int = round(rad_to_deg(Vector2(direction.x, direction.z).angle()))
	
	if direction.z == 0.0 and direction.x == 0:
		is_moving = false
	else:
		is_moving = true
		last_angle = vec_to_angle
	
	if not is_moving:
		match last_angle:
			0:
				sprite_3d.play('idle_s')
			45:
				sprite_3d.play('idle_sw')
			90:
				sprite_3d.play('idle_w')
			135:
				sprite_3d.play('idle_nw')
			180:
				sprite_3d.play('idle_n')
			-135:
				sprite_3d.play('idle_ne')
			-90:
				sprite_3d.play('idle_e')
			-45:
				sprite_3d.play('idle_se')
	else:
		match vec_to_angle:
			0:
				sprite_3d.play('dash_s')
			45:
				sprite_3d.play('dash_sw')
			90:
				sprite_3d.play('dash_w')
			135:
				sprite_3d.play('dash_nw')
			180:
				sprite_3d.play('dash_n')
			-135:
				sprite_3d.play('dash_ne')
			-90:
				sprite_3d.play('dash_e')
			-45:
				sprite_3d.play('dash_se')
		
	
	
	

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
	
