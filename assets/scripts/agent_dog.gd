extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $View/DetectionArea
@onready var path: Path3D = get_tree().current_scene.get_node("Path3D")

enum PlayerState {
	IDLE,
	PATROL,
	ATTACK,
	SEARCH
}

var _state: PlayerState = PlayerState.IDLE
var countState = 0

var points: PackedVector3Array
var indexPoint = -1

var SPEED = 4.0
const RANGE_IDLE = 3.0

var movement_delta: float
var catAliveNode: Node3D
var catSpectre: Node3D
var lastPositionAliveCat: Vector3
var lastAttackCat: Node3D = null
var positionStopInSpectreCar: Vector3 = Vector3.ZERO


func _ready():
	points = path.curve.get_baked_points()
	if points.size() > 0:
		indexPoint = 0
	#_path_patrol()
	_IDLE()
	_state = PlayerState.IDLE

func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("catAlive")):
		#print("Kot wszedl i umarl")
		catAliveNode = body
	if (body.is_in_group("catSpectre")):
		#print("Kot duch wszedl")
		catSpectre = body
	
		
func _on_body_exited(body: Node3D) -> void:
	if (catAliveNode == body):
		#print("Kot wyszedl")
		catAliveNode = null
	if (catSpectre == body):
		#print("Kot duch znikl")
		catSpectre = null



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

func _check_cats() -> bool:
	if catAliveNode:
		lastPositionAliveCat = catAliveNode.global_position
		if _raycast_check_cat(catAliveNode, "catAlive"):
			print("catAlive")
			lastAttackCat = catAliveNode
			navigation_agent_3d.set_target_position(catAliveNode.position)
			_state = PlayerState.ATTACK
			return true
	if catSpectre:
		if _raycast_check_cat(catSpectre, "catSpectre"):
			print("catSpectre")
			lastAttackCat = catSpectre
			if (positionStopInSpectreCar != Vector3.ZERO):
				navigation_agent_3d.set_target_position(positionStopInSpectreCar)
			else:
				navigation_agent_3d.set_target_position(catSpectre.position)
			_state = PlayerState.ATTACK
			return true
	return false

func _IDLE():
	SPEED = 2.0
	await get_tree().create_timer(2).timeout
	var random_position: Vector3 
	random_position.x = global_position.x + snapped(randf_range(-RANGE_IDLE, RANGE_IDLE), 0.1)
	random_position.z = global_position.z + snapped(randf_range(-RANGE_IDLE, RANGE_IDLE), 0.1)
	while abs(random_position.x - global_position.x) < 0.9:
		random_position.x = global_position.x + snapped(randf_range(-RANGE_IDLE, RANGE_IDLE), 0.1)
	while abs(random_position.z - global_position.z) < 0.9:
		random_position.z = global_position.z + snapped(randf_range(-RANGE_IDLE, RANGE_IDLE), 0.1)
	navigation_agent_3d.set_target_position(random_position)
	
	while not navigation_agent_3d.is_target_reachable():
		random_position.x = global_position.x + snapped(randf_range(-RANGE_IDLE, RANGE_IDLE), 0.1)
		random_position.z = global_position.z + snapped(randf_range(-RANGE_IDLE, RANGE_IDLE), 0.1)
		navigation_agent_3d.set_target_position(random_position)
		
	if (randi_range(1, 50) <= countState):
		_state = PlayerState.PATROL
		countState = 0

func _PATROL():
	SPEED = 4.0
	navigation_agent_3d.set_target_position(path.to_global(points[indexPoint]))
	indexPoint += 1
	if (indexPoint >= points.size()):
		indexPoint = 0
	
	if (randi_range(1, 2500) <= countState):
		_state = PlayerState.IDLE
		countState = 0

func _ATTACK():
	if catAliveNode:
		SPEED = 8.0
		
	if catSpectre:
		SPEED = 6.0
	
	if not catAliveNode and not catSpectre and lastAttackCat and lastAttackCat.is_in_group("catSpectre"):
		_state = PlayerState.SEARCH

func _SEARCH():
	SPEED = 4.0
	if lastAttackCat.is_in_group("catSpectre"):
		SPEED = 2.0
		navigation_agent_3d.set_target_position(lastPositionAliveCat)
	

func _entered_collision_cat(body: Node3D):
	if (body.is_in_group("catAlive")):
		get_tree().change_scene_to_file("res://scenes/smierc.tscn") 
	if (body.is_in_group("catSpectre")):
		positionStopInSpectreCar = global_position

func _exited_collision_cat(body: Node3D):
	if (body.is_in_group("catSpectre")):
		positionStopInSpectreCar = Vector3.ZERO

func _navigation_finished():
	match _state:
		PlayerState.IDLE:
			_IDLE()
			print("stoj")
			countState+=1
		PlayerState.PATROL:
			_PATROL()
			print("patroluje")
			countState+=1
		PlayerState.ATTACK:
			_ATTACK()
			print("atak")
		PlayerState.SEARCH:
			_SEARCH()
			print("szuka")
	if _check_cats():
		return
	#print("koniec")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		if catSpectre:
			catSpectre.global_position = Vector3.ZERO
	_ATTACK()
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


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
