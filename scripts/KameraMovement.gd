extends Camera3D


@onready var kot = get_node("../KotCharacterBody3D")  
@export var dead_zone_x: float = 4.0 
@export var dead_zone_z: float = 0.2  
@export var smooth_speed: float = 5.0

var offset = Vector3(10, 20, 10)
var camera_focus_pos: Vector3

func _ready():
	if kot:
		camera_focus_pos = kot.global_position
		global_position = camera_focus_pos + offset

func _process(delta):
	if not kot:
		return
		
	var diff_x = kot.global_position.x - camera_focus_pos.x
	var diff_z = kot.global_position.z - camera_focus_pos.z
	
	
	if abs(diff_x) > dead_zone_x:
		var excess_x = abs(diff_x) - dead_zone_x
		camera_focus_pos.x += sign(diff_x) * excess_x
		
	
	if abs(diff_z) > dead_zone_z:
		var excess_z = abs(diff_z) - dead_zone_z
		camera_focus_pos.z += sign(diff_z) * excess_z
		
	var target_position = camera_focus_pos + offset
	global_position = global_position.lerp(target_position, smooth_speed * delta)
