extends Control

@onready var step_title: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/StepTitle
@onready var step_description: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/StepDescription

var index: int = -1

var step: int = -1:
	set(value):
		match value:
			-1:
				hide()
				return
			0:
				step_title.text = "Sterowanie"
				step_description.text = "Naciskaj przyciski W, A, S, D\naby poruszać kotem."
			1:
				step_title.text = "Hologram"
				step_description.text = "Masz możliwość utworzenia hologramowej wersji twojej postaci."
			2:
				step_title.text = "Tworzenie hologramu"
				step_description.text = "Naciśnij przycisk \"E\" aby mieć możliwość utworzenia hologramu."
			3:
				step_title.text = "Obszar tworzenia hologramu"
				step_description.text = "Naciśnij \"ALT\" aby wyświetlić obszar na którym możesz umieścić hologram."
			4:
				step_title.text = "Stawianie hologramu"
				step_description.text = "Naciśnij prawy przycisk myszy w podświetlonym okręgu, aby móc umieścić hologram na jego obszarze."
			5:
				step_title.text = "Usuwanie hologramu"
				step_description.text = "Kliknij ponownie przycisk \"E\" aby usunąć hologram."
			6:
				step_title.text = "Dodatkowa pomoc"
				step_description.text = "Możesz sterować hologramem klikając prawy przycisk myszy.\nHologram nie pójdzie dalej niż wielkość okręgu (ALT)."
			7:
				step_title.text = "Odległość"
				step_description.text = "Hologram zacznie znikać gdy znajdzie się zbyt daleko od kota."
			8:
				step_title.text = "Zmyłka"
				step_description.text = "Hologram zwraca na siebie uwagę psów, używaj tego do odciągania ich z drogi."
			9:
				step_title.text = "Przeciwnik"
				step_description.text = "Twoim wrogiem będą psy, musisz ich unikać."
			10:
				step_title.text = "Cel gry"
				step_description.text = "Twoim zadaniem jest dostać się do karmy. Powodzenia!"
		show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_key") and not event.is_echo():
		index = (index + 2) % 12 - 1
		step = index
