extends Node3D # (lub MeshInstance3D / StaticBody3D, w zależności od typu Twojego węzła)

func _ready() -> void:
	# 1. Na start ustawiamy skalę miski na 0 (jest niewidoczna)
	scale = Vector3.ZERO
	
	# 2. Tworzymy Tween do animacji
	var tween = create_tween()
	
	# 3. Czekamy dokładnie 2 sekundy przed rozpoczęciem jakiejkolwiek akcji
	tween.tween_interval(2.0)
	
	# 4. Po 2 sekundach miska powiększa się płynnie do nieco większego rozmiaru (1.2)
	tween.tween_property(self, "scale", Vector3.ONE * 1.2, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	# 5. Następnie miska wraca do swojego standardowego rozmiaru (Vector3.ONE czyli 1.0)
	tween.tween_property(self, "scale", Vector3.ONE, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
