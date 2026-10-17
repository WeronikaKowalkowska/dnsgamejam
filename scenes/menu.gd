@tool
extends Control

@onready var window_manager: Control = $WindowManager

@onready var play_btn: Button = $W/VBoxContainer/PlayBtn
@onready var settings_btn: Button = $W/VBoxContainer/SettingsBtn
@onready var credits_btn: Button = $W/VBoxContainer/CreditsBtn
@onready var exit_btn: Button = $W/VBoxContainer/ExitBtn

func _ready() -> void:
	
	window_manager.hide()
	
	settings_btn.pressed.connect(request_window.bind("Settings"))
	credits_btn.pressed.connect(request_window.bind("Credits"))
	exit_btn.pressed.connect(exit)


func request_window(window_name: String) -> void:
	Signals.menu_open_window.emit(window_name)

func exit() -> void:
	get_tree().quit()
