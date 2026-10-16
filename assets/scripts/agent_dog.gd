extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	


func _physics_process(delta: float) -> void:	
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	velocity = direction * SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
