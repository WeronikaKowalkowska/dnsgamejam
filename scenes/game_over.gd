extends Control

@onready var restart_btn: TextureButton = $CenterContainer/VBoxContainer/RestartBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_btn.pressed.connect(restart)


func restart() -> void:
	Utils.is_game_over = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if Utils.is_game_over:
			restart()
