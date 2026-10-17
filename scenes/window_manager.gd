extends Control

@onready var close_btn: TextureButton = $MarginContainer/CloseMargin/CloseBtn
@onready var window_title: Label = $MarginContainer/Window/ContentMargin/Title/WindowTitle

#window type
@onready var settings: Control = $MarginContainer/Window/ContentMargin/Settings
@onready var credits: Control = $MarginContainer/Window/ContentMargin/Credits

var current_window: Control = null

func _ready() -> void:
	settings.hide()
	credits.hide()
	
	Signals.menu_open_window.connect(open_window)
	close_btn.pressed.connect(close_window)

func _input(event: InputEvent) -> void:
	if current_window:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			close_window()
			get_viewport().set_input_as_handled()



func open_window(window_name: String) -> void:
	show()
	window_title.text = window_name
	
	match window_name:
		"Settings":
			current_window = settings
		
		"Credits":
			current_window = credits
	
	current_window.show()
		

func close_window() -> void:
	current_window.hide()
	hide()
	current_window = null
