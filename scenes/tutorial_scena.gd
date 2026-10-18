extends Node3D

const CATTY = preload('uid://c12njkgc8i5vr')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenes.current_scene = "tutorial"
	
	play_gameplay_music()
		

func play_gameplay_music() -> void:
	await get_tree().create_timer(1).timeout
	Audio.current_music = CATTY
	Audio.play_music()

func _exit_tree() -> void:
	Audio.current_music = null
	Audio.stop_music()
	Audio.sfx.stop()
