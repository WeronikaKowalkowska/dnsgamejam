extends Control

@export var exit_btn: Button
@export var cancel_btn: Button

func _ready() -> void:
	exit_btn.pressed.connect(func():
		get_tree().paused = false
		match Scenes.current_scene:
			"main":
				get_tree().change_scene_to_file(Scenes.MENU_FILE)
			"menu":
				get_tree().quit()
		)
	cancel_btn.pressed.connect(resume)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_request") and not event.is_echo():
		if visible:
			get_tree().paused = false
			hide()
			get_viewport().set_input_as_handled()

func resume() -> void:
	hide()
	get_tree().paused = false
