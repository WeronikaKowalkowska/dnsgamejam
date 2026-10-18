extends CharacterBody3D

@onready var label: Label = get_node_or_null("../GUI/Debug/VBoxContainer/Label")
@onready var label_2: Label = get_node_or_null("../GUI/Debug/VBoxContainer/Label2")
@onready var label_3: Label = get_node_or_null("../GUI/Debug/VBoxContainer/Label3")

@onready var sprite_3d: AnimatedSprite3D = $Sprite3D

var is_moving: bool = false
var last_angle: int = 180

@export var speed = 5.0
@export var fall_acceleration = 75

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var default_collision_layer: int
var default_collision_mask: int

# Zmienne do obsługi licznika oddalenia od kota
var timer_oddalenia: float = 0.0
const MAX_ODDALENIE_CZAS: float = 2.0  # Czas w sekundach przed zniknięciem
const MAKSYMALNY_DYSTANS: float = 10.0 # Maksymalna dopuszczalna odległość


func _ready():
	await get_tree().physics_frame
	navigation_agent.target_position = global_position
	
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask
	
		
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

func pokaz_duszka(nowa_pozycja: Vector3):
	global_position = nowa_pozycja
	velocity = Vector3.ZERO
	navigation_agent.target_position = nowa_pozycja
	
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
	if not visible and collision_shape.disabled:
		return

	# Sprawdzamy odległość od żywego kota
	var dystans_od_kota = global_position.distance_to(kot_character.global_position)
	
	if dystans_od_kota > MAKSYMALNY_DYSTANS:
		# Jeśli dystans jest większy niż 10, zwiększamy licznik czasu
		timer_oddalenia += delta
		visible = sin((MAX_ODDALENIE_CZAS - timer_oddalenia) * 15) > 0.0;
		if timer_oddalenia >= MAX_ODDALENIE_CZAS:
			ukryj_duszka()
			print("Duch zniknął z powodu zbyt dużej odległości od kota (> 10 przez 2s).")
			return
	else:
		# Jeśli dystans jest bezpieczny ($\le$ 10), resetujemy licznik
		timer_oddalenia = 0.0
		visible = true
	
	# Grawitacja
	var target_velocity = velocity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0

	var direction = Vector3.ZERO

	# Calculate direction only if navigation is NOT finished
	if not navigation_agent.is_navigation_finished():
		var current_agent_position = global_position
		var next_path_position = navigation_agent.get_next_path_position()

		direction = (next_path_position - current_agent_position).normalized()
		direction.y = 0 
		
		if Vector2(direction.x, direction.z).length() < 0.01:
			direction.x = 0.0
			direction.z = 0.0

	is_moving = direction.x != 0.0 or direction.z != 0.0
	
	var vec_to_angle: int = last_angle
	if is_moving:
		vec_to_angle = round(rad_to_deg(Vector2(direction.x, direction.z).angle()) - 45)
		last_angle = vec_to_angle # Update last_angle so the idle animation faces the correct way
	
	if not is_moving:
			if last_angle > -112.5 and last_angle <= -67.5:
				sprite_3d.play('idle_e')
			if last_angle > -67.5 and last_angle <= -22.5:
				sprite_3d.play('idle_se')
			if last_angle > -22.5 and last_angle <= 22.5:
				sprite_3d.play('idle_s')
			if last_angle > 22.5 and last_angle <= 67.5:
				sprite_3d.play('idle_sw')
			if last_angle > 67.5 and last_angle <= 112.5:
				sprite_3d.play('idle_w')
			if last_angle > 112.5 and last_angle <= 134 or last_angle > -225 and last_angle <= -202.5 :
				sprite_3d.play('idle_nw')
			if last_angle > -202.5 and last_angle <= -157.5:
				sprite_3d.play('idle_n')
			if last_angle > -157.5 and last_angle <= -112.5:
				sprite_3d.play('idle_ne')
			
			
	else:
		if vec_to_angle > -112.5 and vec_to_angle <= -67.5:
			sprite_3d.play('dash_e')
		if vec_to_angle > -67.5 and vec_to_angle <= -22.5:
			sprite_3d.play('dash_se')
		if vec_to_angle > -22.5 and vec_to_angle <= 22.5:
			sprite_3d.play('dash_s')
		if vec_to_angle > 22.5 and vec_to_angle <= 67.5:
			sprite_3d.play('dash_sw')
		if vec_to_angle > 67.5 and vec_to_angle <= 112.5:
			sprite_3d.play('dash_w')
		if vec_to_angle > 112.5 and vec_to_angle <= 134 or vec_to_angle > -225 and vec_to_angle <= -202.5 :
			sprite_3d.play('dash_nw')
		if vec_to_angle > -202.5 and vec_to_angle <= -157.5:
			sprite_3d.play('dash_n')
		if vec_to_angle > -157.5 and vec_to_angle <= -112.5:
			sprite_3d.play('dash_ne')
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	velocity = target_velocity
	move_and_slide()
	
	#label.text = "dir x: " + str(direction.x) + "    dir z: " + str(direction.z)
	#label_2.text = str(last_angle)
	#label_3.text = str(is_moving)

# Odwołania do węzłów:
@onready var kot_character: CharacterBody3D = $"../KotCharacterBody3D"
@onready var kot_duch_agent: NavigationAgent3D = $NavigationAgent3D

func handle_click(click_position: Vector3):
	var kot_pos = kot_character.global_position
	var distance = kot_pos.distance_to(click_position)
	
	var target_position: Vector3
	target_position = click_position
	#if distance <= 6.0:
	#	target_position = click_position
	#else:
	#	var direction = kot_pos.direction_to(click_position)
	#	target_position = kot_pos + direction * 6.0
		
	kot_duch_agent.target_position = target_position
