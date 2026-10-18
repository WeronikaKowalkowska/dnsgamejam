extends Control

@onready var restart_btn: TextureButton = $CenterContainer/VBoxContainer/RestartBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_btn.pressed.connect(restart)


func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
