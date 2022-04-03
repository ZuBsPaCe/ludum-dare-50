extends Spatial


onready var _animation_player = $Lady/AnimationPlayer

func play_animation(anim: String):
	_animation_player.get_animation(anim).loop = true
	_animation_player.play(anim)
