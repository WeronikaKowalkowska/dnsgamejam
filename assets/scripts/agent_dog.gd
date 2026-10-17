extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $View/DetectionArea

const SPEED = 4.0

var movement_delta: float
var catAliveNode: Node3D
var catSpectre: Node3D

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("catAlive")):
		print("Kot wszedl i umarl")
		catAliveNode = body
	if (body.is_in_group("catSpectre")):
		print("Kot duch wszedl")
		catSpectre = body
	
		
func _on_body_exited(body: Node3D) -> void:
	if (catAliveNode == body):
		print("Kot wyszedl")
		catAliveNode = null
	if (catSpectre == body):
		print("Kot duch znikl")
		catSpectre = null


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var random_position := Vector3.ZERO
		random_position.x = randf_range(-5.0, 5.0)
		random_position.z = randf_range(-5.0, 5.0)
		navigation_agent_3d.set_target_position(random_position)
		
	

func _raycast_check_cat(cat: Node3D, group: StringName) -> bool:
	var space_state = get_world_3d().direct_space_state
	var origin = global_position
	var end = cat.global_position
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var raycastResult = space_state.intersect_ray(query)
	if not raycastResult.is_empty():
			var collider: Node = raycastResult["collider"]
			if collider.is_in_group(group):
				return true
	return false

func _check_cats() -> void:
	if catAliveNode:
		if _raycast_check_cat(catAliveNode, "catAlive"):
			print("catAlive")
			navigation_agent_3d.set_target_position(catAliveNode.position)
		return
	if catSpectre:
		if _raycast_check_cat(catSpectre, "catSpectre"):
			print("catSpectre")
			navigation_agent_3d.set_target_position(catSpectre.position)
		return

func _navigation_finished():
	_check_cats()
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-8.0, 8.0)
	random_position.z = randf_range(-8.0, 8.0)
	navigation_agent_3d.set_target_position(random_position)
	
	while not navigation_agent_3d.is_target_reachable():
		random_position.x = randf_range(-8.0, 8.0)
		random_position.z = randf_range(-8.0, 8.0)
		navigation_agent_3d.set_target_position(random_position)
	#print("koniec")

func _physics_process(delta: float) -> void:
	_check_cats()
	if navigation_agent_3d.is_navigation_finished():
		return
	
	movement_delta = SPEED * delta
	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_delta
	
	if global_position.distance_to(next_path_position) > 0.2:
		look_at(next_path_position, Vector3.UP)

	
	if navigation_agent_3d.avoidance_enabled:
		navigation_agent_3d.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	# Add the gravity.
	#if not is_on_floor():
	#	velocity += get_gravity() * delta
	#move_and_slide()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
