extends Node3D

@onready var marker: Sprite3D = $Marker
@onready var micha_area: Area3D = $MichaArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	micha_area.body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	marker.position.y = 0.5 + sin(Time.get_ticks_msec() / 1000.0 * 5) / 15

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		if Scenes.current_scene == "main":
			get_tree().change_scene_to_file("res://scenes/tutorialScena.tscn")
		elif Scenes.current_scene == "tutorial":
			get_tree().change_scene_to_packed(Scenes.VICTORY)
