extends Spatial

enum GameState {
	NONE,
	MAIN_MENU,
	GAME
}


export var player_scene:PackedScene

onready var _game_state := $GameStateMachine



func _ready():

	Globals.setup(
		$Camera2D,
		$EntityContainer,
		player_scene
	)
	
	_game_state.setup(
		GameState.GAME,
		funcref(self, "_on_GameStateMachine_enter_state"),
		FuncRef.new(),
		FuncRef.new()
	)


func _on_GameStateMachine_enter_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			pass

		GameState.GAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		_:
			assert(false, "Unknown game state")
