extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $View/DetectionArea

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var catsNode: Array[Node3D]

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("cats")):
		print("Kot wszedl")
		catsNode.append(body)
		navigation_agent_3d.set_target_position(body.position)
	print("Coś weszło: ", body.name)

func _on_body_exited(body: Node3D) -> void:
	if (body in catsNode):
		print("Kot poszedl")

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-5.0, 5.0)
		random_position.z = randf_range(-5.0, 5.0)
		navigation_agent_3d.set_target_position(random_position)
		
	


func _physics_process(delta: float) -> void:
	
	if (navigation_agent_3d.is_navigation_finished()):
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-5.0, 5.0)
		random_position.z = randf_range(-5.0, 5.0)
		navigation_agent_3d.set_target_position(random_position)
	
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	velocity = direction * SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
