extends CharacterBody3D

@export var speed = 5.0
@export var fall_acceleration = 75

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
# Dodana referencja do kolizji (upewnij się, że Twój węzeł CollisionShape3D tak się nazywa)
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
	await get_tree().physics_frame
	
	navigation_agent.target_position = global_position

func _unhandled_input(event):
	# 1. Obsługa ruchu myszą (prawy przycisk)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var camera = get_viewport().get_camera_3d()
		if not camera:
			return
			
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 1000.0
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result:
			handle_click(result.position)
			
	# 2. Obsługa naciśnięcia klawisza "E"
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			ukryj_duszka()

func ukryj_duszka():
	# Ukrywa wizualnie duszka (i wszystkie jego dzieci, np. modele/sprite'y)
	visible = false
	
	# Wyłącza kształt kolizji, jeśli istnieje
	if collision_shape:
		collision_shape.disabled = true
		
	# Dodatkowo zerujemy warstwy kolizji, żeby fizyka całkowicie go ignorowała
	collision_layer = 0
	collision_mask = 0
	
	print("Duch został ukryty i wyłączono jego kolizje.")

func _physics_process(delta):
	# Grawitacja
	var target_velocity = velocity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0

	if navigation_agent.is_navigation_finished():
		target_velocity.x = 0
		target_velocity.z = 0
		velocity = target_velocity
		move_and_slide()
		return

	var current_agent_position = global_position
	var next_path_position = navigation_agent.get_next_path_position()

	var direction = (next_path_position - current_agent_position).normalized()
	direction.y = 0 
	
	# prędkość w osiach X i Z
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	velocity = target_velocity
	move_and_slide()

# Odwołania do węzłów:
@onready var kot_character: CharacterBody3D = $"../KotCharacterBody3D"  # Odwołanie do drugiego kota w scenie
@onready var kot_duch: CharacterBody3D = self                            # Ten obiekt (sam duch)
@onready var kot_duch_agent: NavigationAgent3D = $NavigationAgent3D     # Dziecko tego węzła

func handle_click(click_position: Vector3):
	# 1. Pozycja wyjściowa kota
	var kot_pos = kot_character.global_position
	
	# 2. Obliczamy odległość w płaszczyźnie poziomej (X, Z)
	var distance = kot_pos.distance_to(click_position)
	
	var target_position: Vector3
	
	# 3. Sprawdzamy warunek odległości
	if distance <= 6.0:
		target_position = click_position
	else:
		var direction = kot_pos.direction_to(click_position)
		target_position = kot_pos + direction * 6.0
		
	# 4. Wysyłamy wyznaczoną pozycję docelową do NavigationAgent duch-kota
	kot_duch_agent.target_position = target_position
