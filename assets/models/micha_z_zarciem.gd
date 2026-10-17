extends Area3D

@onready var kot = $"../KotCharacterBody3D/Sprite3D"
@onready var collider = $CollisionShape3D
@onready var scene = "res://scenes/menu.tscn"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered) # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	# Sprawdzamy, czy obiekt, który wszedł w kolizję, to nasz kot
	# (Możesz też sprawdzić po nazwie: body.name == "KotCharacterBody3D")
	if body.name == "KotCharacterBody3D":
		print("Kot dotarł do celu! Zmiana sceny...")
		
		# Zmiana sceny w Godot 4
		var error = get_tree().change_scene_to_file(scene)
		if error != OK:
			print("Błąd podczas zmiany sceny: ", error)
	
