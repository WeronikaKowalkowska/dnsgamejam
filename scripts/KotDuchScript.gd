extends CharacterBody3D

@export var speed = 5.0
@export var fall_acceleration = 75

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var default_collision_layer: int
var default_collision_mask: int

# Dodaj referencję do swojego Area3D (zmień ścieżkę, jeśli Area3D jest w innym miejscu sceny)
@onready var pulapka_area: Area3D = $"../Area3D" 

func _ready():
	await get_tree().physics_frame
	navigation_agent.target_position = global_position
	
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask
	
	# Łączymy sygnał body_entered z kodu automatycznie podczas startu gry:
	if pulapka_area:
		pulapka_area.body_entered.connect(_on_pulapka_body_entered)

# Funkcja wykonująca się, gdy cokolwiek wejdzie w obszar Area3D
func _on_pulapka_body_entered(body: Node3D):
	# Sprawdzamy czy to dokładnie nasz duch
	if body == self:
		print("Duch dotknął obszaru i został usunięty!")
		queue_free() # Usuwa obiekt duszka z gry
		
func _unhandled_input(event):
	# Obsługa naciśnięcia klawisza "E" – ukrywanie duszka
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			ukryj_duszka()

	# Obsługa kliknięcia prawym przyciskiem myszy
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
		
		# KLUCZOWA ZMIANA DLA IZOMETRII:
		# Ustalamy maskę kolizji tak, aby raycast ignorował ściany i trafiał tylko w podłogę.
		# Jeśli Twoja podłoga jest na 2. warstwie, maska to 2 (czyli wartość binarna 2 lub 1 << 1).
		# Możesz też wpisać konkretną maskę warstwy podłogi. Dla 2. warstwy jest to 2.
		query.collision_mask = 4  # Zmień numer, jeśli Twoja podłoga jest na innej warstwie!
		
		var result = space_state.intersect_ray(query)
		
		if result:
			if visible:
				# Gdy duch jest widoczny – wyznaczamy cel poruszania się
				handle_click(result.position)
			else:
				# Gdy duch jest ukryty – próbujemy go postawić
				probuj_pojawic_duszka(result.position)

func ukryj_duszka():
	visible = false
	if collision_shape:
		collision_shape.disabled = true
	collision_layer = 0
	collision_mask = 0

func pokaz_duszka(nowa_pozycja: Vector3):
	global_position = nowa_pozycja
	velocity = Vector3.ZERO
	navigation_agent.target_position = nowa_pozycja
	
	visible = true
	if collision_shape:
		collision_shape.disabled = false
	
	collision_layer = default_collision_layer
	collision_mask = default_collision_mask

func probuj_pojawic_duszka(click_position: Vector3):
	var kot_pos = kot_character.global_position
	var distance = kot_pos.distance_to(click_position)
	
	var docelowa_pozycja: Vector3
	
	# Ograniczenie odległości od kota do maksymalnie 6 jednostek
	if distance <= 6.0:
		docelowa_pozycja = click_position
	else:
		var direction = kot_pos.direction_to(click_position)
		docelowa_pozycja = kot_pos + direction * 6.0

	# 1. Sprawdzamy czy miejsce nie koliduje ze ścianą (np. czy nie próbujemy postawić duszka wewnątrz ściany)
	if not can_place_at(docelowa_pozycja):
		print("Nie można postawić duszka – kolizja ze ścianą!")
		return

	# 2. Ustawiamy wysokość dokładnie na pozycji trafionej podłogi
	docelowa_pozycja.y = click_position.y
	pokaz_duszka(docelowa_pozycja)

func can_place_at(target_pos: Vector3) -> bool:
	var transform_target = Transform3D(global_transform.basis, target_pos)
	var params = PhysicsTestMotionParameters3D.new()
	params.from = transform_target
	params.motion = Vector3.ZERO
	params.exclude_bodies = [get_rid(), kot_character.get_rid()]
	
	var result = PhysicsTestMotionResult3D.new()
	var is_colliding = PhysicsServer3D.body_test_motion(get_rid(), params, result)
	
	return not is_colliding

func _physics_process(delta):
	if not visible:
		return

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
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	velocity = target_velocity
	move_and_slide()

# Odwołania do węzłów:
@onready var kot_character: CharacterBody3D = $"../KotCharacterBody3D"
@onready var kot_duch_agent: NavigationAgent3D = $NavigationAgent3D

func handle_click(click_position: Vector3):
	var kot_pos = kot_character.global_position
	var distance = kot_pos.distance_to(click_position)
	
	var target_position: Vector3
	
	if distance <= 6.0:
		target_position = click_position
	else:
		var direction = kot_pos.direction_to(click_position)
		target_position = kot_pos + direction * 6.0
		
	kot_duch_agent.target_position = target_position
