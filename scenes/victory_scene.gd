extends Control

const CATTY = preload('uid://c12njkgc8i5vr')

@onready var exit_btn: Button = $CenterContainer/VBoxContainer/exit_btn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.current_music = CATTY
	Audio.play_music()
	exit_btn.pressed.connect(main_menu)


func main_menu() -> void:
	get_tree().change_scene_to_file(Scenes.MENU_FILE)
