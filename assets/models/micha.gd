extends Node3D

@onready var marker: Sprite3D = $Marker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	marker.position.y = 0.5 + sin(Time.get_ticks_msec() / 1000.0 * 5) / 15
