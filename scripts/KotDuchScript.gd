extends CharacterBody3D

@export var speed = 5.0
@export var fall_acceleration = 75

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# Odwołanie do węzła wizualnego duszka
@onready var sprite_wizualny: Sprite3D = $Sprite3D 

var default_collision_layer: int
var default_collision_mask: int

# Zmienne do obsługi licznika oddalenia od kota
var timer_oddalenia: float = 0.0
const MAX_ODDALENIE_CZAS: float = 4.0  # Zmienione na 4 sekundy przed zniknięciem
const MAKSYMALNY_DYSTANS: float = 10.0 # Maksymalna dopuszczalna odległość


func _ready():
	await get_tree().physics_frame
	navigation_agent.target_position = global_position
	
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask
	
	ustaw_alfa_duszka(1.0)
		
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
		
		# Ustalamy maskę kolizji tak, aby raycast ignorował ściany i trafiał tylko w podłogę (3 warstwa = 4)
		query.collision_mask = 4 
		
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
	timer_oddalenia = 0.0 # Resetujemy licznik po ukryciu
	ustaw_alfa_duszka(1.0)

func pokaz_duszka(nowa_pozycja: Vector3):
	global_position = nowa_pozycja
	velocity = Vector3.ZERO
	navigation_agent.target_position = nowa_pozycja
	
	ustaw_alfa_duszka(1.0)
	
	visible = true
	if collision_shape:
		collision_shape.disabled = false
	
	collision_layer = default_collision_layer
	collision_mask = default_collision_mask
	timer_oddalenia = 0.0 # Resetujemy licznik przy pojawieniu się

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

	# 1. Sprawdzamy czy miejsce nie koliduje ze ścianą
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

	# Sprawdzamy odległość od żywego kota
	var dystans_od_kota = global_position.distance_to(kot_character.global_position)
	
	if dystans_od_kota > MAKSYMALNY_DYSTANS:
		# Jeśli dystans jest większy niż 10, zwiększamy licznik czasu
		timer_oddalenia += delta
		
		# Obliczamy postęp zanikania od 0.0 (start) do 1.0 (zniknięcie po 4s)
		var progres_zanikania = clamp(timer_oddalenia / MAX_ODDALENIE_CZAS, 0.0, 1.0)
		
		# Efekt pulsowania podczas zanikania
		var predkosc_pulsowania = 15.0 
		var intensywnosc_pulsowania = (sin(Time.get_ticks_msec() * 0.001 * predkosc_pulsowania) + 1.0) / 2.0
		
		var bazowe_alfa = 1.0 - progres_zanikania
		var finalne_alfa = bazowe_alfa * (0.5 + intensywnosc_pulsowania * 0.5) 
		
		ustaw_alfa_duszka(finalne_alfa)
		
		if timer_oddalenia >= MAX_ODDALENIE_CZAS:
			ukryj_duszka()
			print("Duch zniknął z powodu zbyt dużej odległości od kota (> 10 przez 4s).")
			return
	else:
		# Jeśli dystans jest bezpieczny ($\le$ 10), resetujemy licznik i przezroczystość
		if timer_oddalenia > 0.0:
			timer_oddalenia = 0.0
			ustaw_alfa_duszka(1.0)

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

func ustaw_alfa_duszka(wartość_alfa: float):
	if not sprite_wizualny:
		return
	sprite_wizualny.modulate.a = wartość_alfa

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
