extends AnimatedSprite3D

var is_moving: bool = false
var last_direction: float = 0.0
var previous_position: Vector3

func _ready() -> void:
	previous_position = global_position

func _physics_process(delta: float) -> void:
	var current_speed: float = global_position.distance_to(previous_position) / delta
	is_moving = current_speed > 0.01
	previous_position = global_position

	if is_moving:
		last_direction = rad_to_deg(global_rotation.y)

	var direction: float = last_direction
	var animation_prefix: String = "dash_" if is_moving else "idle_"

	if direction > -22.5 and direction <= 22.5:
		play(animation_prefix + "ne")
	elif direction > 22.5 and direction <= 67.5:
		play(animation_prefix + "n")
	elif direction > 67.5 and direction <= 112.5:
		play(animation_prefix + "nw")
	elif direction > 112.5 and direction <= 157.5:
		play(animation_prefix + "w")
	elif direction > 157.5 or direction <= -157.5:
		play(animation_prefix + "sw")
	elif direction > -157.5 and direction <= -112.5:
		play(animation_prefix + "s")
	elif direction > -112.5 and direction <= -67.5:
		play(animation_prefix + "se")
	elif direction > -67.5 and direction <= -22.5:
		play(animation_prefix + "e")
