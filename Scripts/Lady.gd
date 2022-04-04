extends Spatial


const Task := preload("res://Scripts/Task.gd").Task


onready var _animation_player = $Lady/AnimationPlayer
onready var _audio_talk = $AudioTalk


var _random_audios := []
var _random_audio_cooldown := Cooldown.new()
var _audio_was_playing := false
var _random_audio_index = 0



func play_animation(anim: String):
	_animation_player.get_animation(anim).loop = true
	_animation_player.play(anim)


func begin_task(task):
	_random_audios.clear()
	
	match task:
		Task.MEDICINE:
			_random_audios = [
				load("res://Sounds/Lady/Task1-I need medicine.ogg"),
				load("res://Sounds/Lady/Task1-Where could it be.ogg")
			]
		Task.SNAILS:
			_random_audios = [
				load("res://Sounds/Lady/Task2-Hurry.ogg"),
				load("res://Sounds/Lady/Task2-Poor flowers.ogg")
			]
	
	
	if _random_audios.size() > 0:
		_random_audio_cooldown.restart_with(randf() * 10 + 10)
		_random_audios.shuffle()
		_random_audio_index
		

func _ready():
	_random_audio_cooldown.setup(self, 0, true)



func _process(delta):
	
	if _random_audios.size() > 0:
		if _audio_talk.playing:
			_audio_was_playing = true
		elif _audio_was_playing:
			_random_audio_cooldown.restart_with(randf() * 10 + 10)
		else:
			if _random_audio_index >= _random_audios.size():
				_random_audio_index = 0
			_audio_talk.stream = _random_audios[_random_audio_index]
			_audio_talk.play()
			
		
