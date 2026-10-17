extends CharacterBody3D

@export var speed = 5.0
@export var fall_acceleration = 75

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	await get_tree().physics_frame
	
	navigation_agent.target_position = global_position

func _unhandled_input(event):
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
			navigation_agent.target_position = result.position

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
