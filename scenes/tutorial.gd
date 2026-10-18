extends Control

@onready var step_title: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/StepTitle
@onready var step_description: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/StepDescription

var step: int = -1:
	set(value):
		if value > 10:
			step = -1
			hide()
			return
			
		step = value
		match step:
			-1:
				hide()
				return
			0:
				step_title.text = "Sterowanie"
				step_description.text = "Naciskaj przyciski W, A, S, D\naby poruszać kotem.\n(Spacja)"
			1:
				step_title.text = "Hologram"
				step_description.text = "Masz możliwość utworzenia hologramowej wersji twojej postaci.\n(Spacja)"
			2:
				step_title.text = "Tworzenie hologramu"
				step_description.text = "Naciśnij przycisk \"E\" aby mieć możliwość utworzenia hologramu.\n(Spacja)"
			3:
				step_title.text = "Obszar tworzenia hologramu"
				step_description.text = "Naciśnij \"ALT\" aby wyświetlić obszar na którym możesz umieścić hologram.\n(Spacja)"
			4:
				step_title.text = "Stawianie hologramu"
				step_description.text = "Naciśnij prawy przycisk myszy w podświetlonym okręgu, aby móc umieścić hologram na jego obszarze.\n(Spacja)"
			5:
				step_title.text = "Usuwanie hologramu"
				step_description.text = "Kliknij ponownie przycisk \"E\" aby usunąć hologram.\n(Spacja)"
			6:
				step_title.text = "Dodatkowa pomoc"
				step_description.text = "Możesz sterować hologramem klikając prawy przycisk myszy.\nHologram nie pójdzie dalej niż wielkość okręgu (ALT).\n(Spacja)"
			7:
				step_title.text = "Odległość"
				step_description.text = "Hologram zacznie znikać gdy znajdzie się zbyt daleko od kota.\n(Spacja)"
			8:
				step_title.text = "Zmyłka"
				step_description.text = "Hologram zwraca na siebie uwagę psów, używaj tego do odciągania ich z drogi.\n(Spacja)"
			9:
				step_title.text = "Przeciwnik"
				step_description.text = "Twoim wrogiem będą psy, musisz ich unikać.\n(Spacja)"
			10:
				step_title.text = "Cel gry"
				step_description.text = "Twoim zadaniem jest dostać się do karmy. Powodzenia!\n(Spacja)"
		show()

func _ready() -> void:
	# Uruchamiamy pierwszy krok zaraz po załadowaniu sceny
	step = 0

func _input(event: InputEvent) -> void:
	if step == -1:
		return

	# Reagujemy wyłącznie na naciśnięcie spacji (pomijając powtarzanie przytrzymanego klawisza)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			step += 1
