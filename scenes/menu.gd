@tool
extends Control
const MAIN_THEME_2 = preload('uid://d28uuuwf0amvr')

@onready var window_manager: Control = $WindowManager
@onready var quit_prompt: Control = $QuitPrompt

@onready var play_btn: Button = $W/VBoxContainer/PlayBtn
@onready var settings_btn: Button = $W/VBoxContainer/SettingsBtn
@onready var credits_btn: Button = $W/VBoxContainer/CreditsBtn
@onready var exit_btn: Button = $W/VBoxContainer/ExitBtn

func _ready() -> void:
	Scenes.current_scene = "menu"
	
	Audio.current_music = MAIN_THEME_2
	Audio.play_music()
	
	window_manager.hide()
	quit_prompt.hide()
	
	play_btn.pressed.connect(func():
		Audio.stop_music()
		get_tree().change_scene_to_packed(Scenes.MAIN)
		)
	
	settings_btn.pressed.connect(request_window.bind("Settings"))
	credits_btn.pressed.connect(request_window.bind("Credits"))
	exit_btn.pressed.connect(func(): quit_prompt.show())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_request") and not event.is_echo():
		if window_manager.current_window == null:
			quit_prompt.show()

func request_window(window_name: String) -> void:
	Signals.menu_open_window.emit(window_name)
