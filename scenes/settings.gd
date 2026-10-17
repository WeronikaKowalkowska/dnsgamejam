extends Control

@onready var music_slider: HSlider = $VBoxContainer/HBoxContainer2/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/HBoxContainer3/SfxSlider
@onready var full_screen_checkbox: CheckBox = $VBoxContainer/HBoxContainer/FullScreenCheckbox

func _ready() -> void:
	visibility_changed.connect(setup)
	print(1)
	music_slider.value_changed.connect(music_value_changed)
	sfx_slider.value_changed.connect(sfx_value_changed)
	full_screen_checkbox.toggled.connect(fullscreen_pressed)

func setup() -> void:
	if visible:
		music_slider.value = Utils.music_volume
		sfx_slider.value = Utils.sfx_volume

func music_value_changed(value: float) -> void:
	Utils.music_volume = int(value)

func sfx_value_changed(value: float) -> void:
	Utils.sfx_volume = int(value)

func fullscreen_pressed(on: bool) -> void:
	if on:
		get_window().size = Vector2i(1920, 1080)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().size = Vector2i(1280, 720)
