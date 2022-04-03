extends CanvasLayer

var GameState := preload("res://Scripts/GameState.gd").GameState

var continue_glow := preload("res://Objects/Menu/Textures/Glow/Continue.png")
var continue_no_glow := preload("res://Objects/Menu/Textures/NoGlow/Continue.png")

func update_controls():
	pass


func _on_StartStoryButton_mouse_entered():
	$Story/VBoxContainer/StartStoryButton.texture = continue_glow


func _on_StartStoryButton_mouse_exited():
	$Story/VBoxContainer/StartStoryButton.texture = continue_no_glow


func _on_StartStoryButton_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		owner.switch_game_state(GameState.GAME)

