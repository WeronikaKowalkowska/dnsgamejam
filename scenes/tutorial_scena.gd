extends Node3D

@onready var micha_area: Area3D = $Micha/MichaArea
const CATTY = preload('uid://c12njkgc8i5vr')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Scenes.current_scene = "main"
	
	play_gameplay_music()
	
	micha_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		#get_tree().call_deferred("change_scene_to_file", Scenes.MENU_FILE)
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		

func play_gameplay_music() -> void:
	await get_tree().create_timer(1).timeout
	Audio.current_music = CATTY
	Audio.play_music()

func _exit_tree() -> void:
	Audio.current_music = null
	Audio.stop_music()
