extends Node

var current_language: int = 1:
	set(value):
		match value:
			0:
				TranslationServer.set_locale("English")
			1:
				TranslationServer.set_locale("Polish")
		
		current_language = value

var music_volume: int = 50:
	set(value):
		music_volume = value
		Signals.music_volume_changed.emit(value)

var sfx_volume: int = 50:
	set(value):
		sfx_volume = value
		Signals.sfx_volume_changed.emit(value)

var all_buttons: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_language = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
