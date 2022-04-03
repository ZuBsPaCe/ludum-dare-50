extends Spatial

var GameState := preload("res://Scripts/GameState.gd").GameState

export var player_scene:PackedScene

onready var _game_state := $GameStateMachine



func _ready():

	Globals.setup(
		$Camera2D,
		$EntityContainer,
		player_scene
	)
	
	_game_state.setup(
		GameState.MAIN_MENU,
		funcref(self, "_on_GameStateMachine_enter_state"),
		FuncRef.new(),
		funcref(self, "_on_GameStateMachine_leave_state")
	)
	
	$MainMenuOverlay/MainMenu.visible = false
	$StoryOverlay/Story.visible = false


func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		if _game_state.current == GameState.GAME:
			if event.scancode == KEY_ESCAPE:
				switch_game_state(GameState.PAUSED)
		
		

func switch_game_state(new_game_state):
	_game_state.set_state(new_game_state)

func get_game_state():
	return _game_state.current


func _on_GameStateMachine_enter_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			get_tree().paused = true
			$MainMenuOverlay/MainMenu.visible = true
			$MainMenuOverlay.update_controls()

		GameState.NEW_GAME:
			Globals.reset_game()
			switch_game_state(GameState.STORY)
			
			$MainAnimationPlayer.stop()
			$MainAnimationPlayer.play("Task1-Start")

		GameState.STORY:
			$StoryOverlay/Story.visible = true
			$StoryOverlay.update_controls()

		GameState.GAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
		
		GameState.PAUSED:
			get_tree().paused = true
			$MainMenuOverlay/MainMenu.visible = true
			$MainMenuOverlay.update_controls()
		
		GameState.CONTINUE:
			switch_game_state(GameState.GAME)

		_:
			assert(false, "Unknown game state")


func _on_GameStateMachine_leave_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			$MainMenuOverlay/MainMenu.visible = false
		
		GameState.STORY:
			$StoryOverlay/Story.visible = false

		GameState.NEW_GAME:
			pass
			
		GameState.GAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		GameState.PAUSED:
			$MainMenuOverlay/MainMenu.visible = false
			pass
		
		GameState.CONTINUE:
			$MainMenuOverlay/MainMenu.visible = false
			pass

		_:
			assert(false, "Unknown game state")
