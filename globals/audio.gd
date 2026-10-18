extends Node

var music: AudioStreamPlayer = AudioStreamPlayer.new()
var sfx: AudioStreamPlayer = AudioStreamPlayer.new()

var current_music: AudioStream
var music_muted: bool = true if Utils.music_volume < 1 else false

func _ready() -> void:
	add_child(music)
	add_child(sfx)
	
	music.volume_db = linear_to_db(Utils.music_volume / 100.0)
	sfx.volume_db = linear_to_db(Utils.sfx_volume / 100.0)
	
	Signals.music_volume_changed.connect(update_music_volume)
	Signals.sfx_volume_changed.connect(update_sfx_volume)


func play_music() -> void:
	music.stream = current_music
	music.play()

func stop_music() -> void:
	music.stop()

func play_sound(audiofile: AudioStream, offset: float = 0.0) -> void:
	sfx.stream = audiofile
	sfx.play(offset)

func update_music_volume(value: int) -> void:
	if value < 1:
		music_muted = true
		music.stop()
	else:
		if music_muted:
			music_muted = false
			play_music()
	music.volume_db = linear_to_db(value / 100.0)

func update_sfx_volume(value: int) -> void:
	sfx.volume_db = linear_to_db(value / 100.0)
