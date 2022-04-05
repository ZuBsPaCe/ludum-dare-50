extends Spatial

const GameState := preload("res://Scripts/GameState.gd").GameState
const Task := preload("res://Scripts/Task.gd").Task

export var player_scene:PackedScene

onready var _game_state = $GameStateMachine
onready var _music_slider = $MainMenuOverlay/MainMenu/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/MusicSlider
onready var _sound_slider = $MainMenuOverlay/MainMenu/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/SoundSlider

const SETTINGS_PATH := "user://settings.cfg"



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
	$Flowers.visible = false
	$OutroOverlay.visible = false
	
	$"MainMenu Camera".current = true
	
	_load_settings()


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


func play_sound(name: String):
	get_node("Sounds/" + name).play()
	
func play_music(name: String):
	$Sounds/MusicPlayer.stop()
	$Sounds/MusicPlayer.stream = load("res://Sounds/Music/" + name + ".ogg")
	$Sounds/MusicPlayer.play()


func play_animation(anim):
	$MainAnimationPlayer.play(anim)

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
			
			for snail in $Snails.get_children():
				snail.visible = true
			$Snails.visible = true
			
			for flower in $Flowers.get_children():
				flower.visible = true
			$Flowers.visible = false
			
			$Lady/Flower.visible = false
			
			$DoorMain.rotation.y = 0
			
			$MainAnimationPlayer.stop()
			$MainAnimationPlayer.play("Task1-Start")

		GameState.STORY:
			$StoryOverlay.visible = true
			$StoryOverlay.update_controls()

		GameState.GAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false

		
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
			_save_settings()

		GameState.NEW_GAME:
			pass
			
		GameState.GAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		GameState.PAUSED:
			$MainMenuOverlay.visible = false
		
		GameState.CONTINUE:
			$MainMenuOverlay.visible = false
			_save_settings()

		_:
			assert(false, "Unknown game state")
			

func begin_task(task: int):
	$Lady.begin_task(task)


func _on_Lady_body_entered(body):
	if body.is_in_group("Player"):
		Globals.player_near_lady = true
		
		if Globals.has_medicine:
			Globals.has_medicine = false
			$Player/Ducky/Armature/Skeleton/DuckyBeakBottom/Medicine.visible = false
			$Player/Ducky/Armature/Skeleton/DuckyBeakBottom/Flower.visible = false
			$MainAnimationPlayer.play("Task2-Start")
		if Globals.snail_count >= 8:
			Globals.snail_count = 0
			$MainAnimationPlayer.play("Task3-Start")


func _on_Lady_body_exited(body):
	if body.is_in_group("Player"):
		Globals.player_near_lady = false

func start_outro():
	print("Starting outro")
	Globals.flower_count = 0
	$Player/Ducky/Armature/Skeleton/DuckyBeakBottom/Flower.visible = false
	$Lady/Flower.visible = true
	$MainAnimationPlayer.play("Outro")

func _on_MusicSlider_value_changed(value):
	$Sounds/MusicBling.stop()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))
	$Sounds/MusicBling.play()



func _on_SoundSlider_value_changed(value):
	$Sounds/AudioBling.stop()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear2db(value))
	$Sounds/AudioBling.play()


func _save_settings():
	var file = File.new()
	file.open(SETTINGS_PATH, File.WRITE)
	file.store_var(_music_slider.value)
	file.store_var(_sound_slider.value)
	file.close()


func _load_settings():
	var file = File.new()
	if file.file_exists(SETTINGS_PATH):
		file.open(SETTINGS_PATH, File.READ)
		_music_slider.value = file.get_var()
		_sound_slider.value = file.get_var()


func exit():
	_save_settings()
	get_tree().quit()

