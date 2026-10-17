@tool
extends Control
const MAIN_THEME_2 = preload('uid://d28uuuwf0amvr')
const CLICK_SOUND_2P_0 = preload('uid://8wy38mi7jk7a')

@onready var window_manager: Control = $WindowManager
@onready var quit_prompt: Control = $QuitPrompt

@onready var play_btn: Button = $W/VBoxContainer/HBoxContainer/PlayBtn
@onready var settings_btn: Button = $W/VBoxContainer/HBoxContainer2/SettingsBtn
@onready var credits_btn: Button = $W/VBoxContainer/HBoxContainer3/CreditsBtn
@onready var quit_btn: Button = $W/VBoxContainer/HBoxContainer4/QuitBtn

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
	
	Utils.all_buttons[play_btn] = play_btn
	Utils.all_buttons[settings_btn] = settings_btn
	Utils.all_buttons[credits_btn] = credits_btn
	Utils.all_buttons[quit_btn] = quit_btn
	
	for button in Utils.all_buttons:
		if is_instance_valid(button):
			button.pressed.connect(any_button_pressed)
	
	settings_btn.pressed.connect(request_window.bind("Settings"))
	credits_btn.pressed.connect(request_window.bind("Credits"))
	quit_btn.pressed.connect(func(): quit_prompt.show())

func any_button_pressed() -> void:
	Audio.play_sound(CLICK_SOUND_2P_0, 0.145)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_request") and not event.is_echo():
		if window_manager.current_window == null:
			quit_prompt.show()

func request_window(window_name: String) -> void:
	Signals.menu_open_window.emit(window_name)

func _exit_tree() -> void:
	Utils.all_buttons.erase(play_btn)
	Utils.all_buttons.erase(settings_btn)
	Utils.all_buttons.erase(credits_btn)
	Utils.all_buttons.erase(quit_btn)
