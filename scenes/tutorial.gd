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
				step_description.text = "Naciskaj przyciski W, A, S, D\naby poruszać kotem."
			1:
				step_title.text = "Hologram"
				step_description.text = "Masz możliwość utworzenia hologramowej wersji twojej postaci.\n(Spacja)"
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

	var can_advance = false

	# Sprawdzamy warunek w zależności od bieżącego kroku tutorialu
	match step:
		0: # W, A, S, D
			if event is InputEventKey and event.pressed and not event.echo:
				if event.keycode in [KEY_W, KEY_A, KEY_S, KEY_D]:
					can_advance = true
		1: # Informacyjny - Spacja
			if event is InputEventKey and event.pressed and not event.echo:
				if event.keycode == KEY_SPACE:
					can_advance = true
		2: # Przycisk "E"
			if event is InputEventKey and event.pressed and not event.echo:
				if event.keycode == KEY_E:
					can_advance = true
		3: # Klawisz "ALT"
			if event is InputEventKey and event.pressed and not event.echo:
				if event.keycode == KEY_ALT:
					can_advance = true
		4: # Prawy przycisk myszy
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				can_advance = true
		5: # Przycisk "E"
			if event is InputEventKey and event.pressed and not event.echo:
				if event.keycode == KEY_E:
					can_advance = true
		6: # Prawy przycisk myszy
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				can_advance = true
		7, 8, 9, 10: # Kroki informacyjne - Spacja
			if event is InputEventKey and event.pressed and not event.echo:
				if event.keycode == KEY_SPACE:
					can_advance = true

	# Jeśli warunek kroku został spełniony, przechodzimy do następnego
	if can_advance:
		step += 1
