extends Node


var music_volume: int = 100:
	set(value):
		music_volume = value
		Signals.music_volume_changed.emit(value)

var sfx_volume: int = 100:
	set(value):
		sfx_volume = value
		Signals.sfx_volume_changed.emit(value)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
