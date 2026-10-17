extends CanvasLayer

@onready var quit_prompt: Control = $QuitPrompt


func _ready() -> void:
	quit_prompt.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit_request") and not event.is_echo():
		quit_prompt.visible = true
		get_tree().paused = true
