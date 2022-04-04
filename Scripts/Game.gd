extends Spatial

const GameState := preload("res://Scripts/GameState.gd").GameState
const Task := preload("res://Scripts/Task.gd").Task

export var player_scene:PackedScene

onready var _game_state := $GameStateMachine



func _ready():

	Globals.setup()
	
	_game_state.setup(
		GameState.MAIN_MENU,
		funcref(self, "_on_GameStateMachine_enter_state"),
		FuncRef.new(),
		funcref(self, "_on_GameStateMachine_leave_state")
	)
	
	$MainMenuOverlay.visible = false
	$StoryOverlay.visible = false
	$AimOverlay.visible = false
	$Snails.visible = false
	
	$"MainMenu Camera".current = true


func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		if _game_state.current == GameState.GAME:
			if event.scancode == KEY_ESCAPE:
				switch_game_state(GameState.PAUSED)
		
		
		
func _process(delta):
	if Globals.aim_shown:
		$AimOverlay/Aim.rect_position = Globals.aim_anchor + Globals.aim_offset
		

func switch_game_state(new_game_state):
	_game_state.set_state(new_game_state)

func get_game_state():
	return _game_state.current


func show_aim():
	$AimOverlay.visible = true
	
func hide_aim():
	$AimOverlay.visible = false


func play_sound(name):
	get_node("Sounds/" + name).play()


func _on_GameStateMachine_enter_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			get_tree().paused = true
			$MainMenuOverlay.visible = true
			$MainMenuOverlay.update_controls()
			$Snails.visible = false

		GameState.NEW_GAME:
			Globals.reset_game()
			$Player.reset_game()
			switch_game_state(GameState.STORY)
			
			$MainAnimationPlayer.stop()
			$MainAnimationPlayer.play("Task1-Start")

		GameState.STORY:
			$StoryOverlay.visible = true
			$StoryOverlay.update_controls()

		GameState.GAME:
			$DoorMain.rotation.y = 0
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			$Snails.visible = true
			for snail in $Snails.get_children():
				snail.visible = true
		
		GameState.PAUSED:
			get_tree().paused = true
			$MainMenuOverlay.visible = true
			$MainMenuOverlay.update_controls()
		
		GameState.CONTINUE:
			switch_game_state(GameState.GAME)

		_:
			assert(false, "Unknown game state")


func _on_GameStateMachine_leave_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			$MainMenuOverlay.visible = false
		
		GameState.STORY:
			$StoryOverlay.visible = false

		GameState.NEW_GAME:
			pass
			
		GameState.GAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		GameState.PAUSED:
			$MainMenuOverlay.visible = false
			pass
		
		GameState.CONTINUE:
			$MainMenuOverlay.visible = false
			pass

		_:
			assert(false, "Unknown game state")
			

func begin_task(task: int):
	$Lady.begin_task(task)


func _on_Lady_body_entered(body):
	if body.is_in_group("Player"):
		if Globals.has_medicine:
			Globals.has_medicine = false
			$Player/Ducky/Armature/Skeleton/DuckyBeakBottom/Medicine.visible = false
			$MainAnimationPlayer.play("Task2-Start")
		if Globals.snail_count >= 8:
			Globals.snail_count = 0
			$MainAnimationPlayer.play("Task3-Start")

