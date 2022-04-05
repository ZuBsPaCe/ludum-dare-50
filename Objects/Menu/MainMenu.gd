extends CanvasLayer

var GameState := preload("res://Scripts/GameState.gd").GameState

var new_game_glow := preload("res://Objects/Menu/Textures/Glow/New Game.png")
var new_game_no_glow := preload("res://Objects/Menu/Textures/NoGlow/New Game.png")

var exit_glow := preload("res://Objects/Menu/Textures/Glow/Exit.png")
var exit_no_glow := preload("res://Objects/Menu/Textures/NoGlow/Exit.png")

var continue_glow := preload("res://Objects/Menu/Textures/Glow/Continue.png")
var continue_no_glow := preload("res://Objects/Menu/Textures/NoGlow/Continue.png")


func update_controls():
	if OS.has_feature("HTML5"):
		$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer2/ExitButton.visible = false
	
	$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer3/ContinueButton.visible = owner.get_game_state() == GameState.PAUSED


func _on_NewGameButton_mouse_entered():
	$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer3/NewGameButton.texture = new_game_glow


func _on_NewGameButton_mouse_exited():
	$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer3/NewGameButton.texture = new_game_no_glow


func _on_NewGameButton_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		owner.play_sound("AudioBling")
		owner.switch_game_state(GameState.NEW_GAME)


func _on_ExitButton_mouse_entered():
	$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer2/ExitButton.texture = exit_glow


func _on_ExitButton_mouse_exited():
	$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer2/ExitButton.texture = exit_no_glow


func _on_ExitButton_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		owner.exit()


func _on_ContinueButton_mouse_entered():
	$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer3/ContinueButton.texture = continue_glow


func _on_ContinueButton_mouse_exited():
	$MainMenu/VBoxContainer/HBoxContainer/VBoxContainer3/ContinueButton.texture = continue_no_glow


func _on_ContinueButton_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		owner.play_sound("AudioBling")
		owner.switch_game_state(GameState.CONTINUE)
