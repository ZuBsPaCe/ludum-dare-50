extends KinematicBody

onready var _camera := $SpringArm/Camera
onready var _spring_arm := $SpringArm
onready var _ducky := $Ducky
onready var _ducky_animation_walk := $Ducky/AnimationPlayer


export var movement_enabled := true


var _ducky_animation_head : AnimationPlayer
var _ducky_animation_tail : AnimationPlayer
var _ducky_animation_wings : AnimationPlayer

var _gravity := 0.0
var _spring_arm_offset := 0.0
var _ducky_rotation_degrees: float


var _reset_idle := true
var _idle_cooldown_body := Cooldown.new()
var _idle_cooldown_head := Cooldown.new()
var _idle_cooldown_tail := Cooldown.new()
var _idle_cooldown_flatter := Cooldown.new()




func _ready():
	_spring_arm_offset = _spring_arm.translation.y
	_ducky_rotation_degrees = _ducky.rotation_degrees.y
	
	_idle_cooldown_body.setup(self, 0.0, true)
	_idle_cooldown_head.setup(self, 0.0, true)
	_idle_cooldown_tail.setup(self, 0.0, true)
	_idle_cooldown_flatter.setup(self, 0.0, true)
	
	_ducky_animation_head = _ducky_animation_walk.duplicate()
	_ducky_animation_tail = _ducky_animation_walk.duplicate()
	_ducky_animation_wings = _ducky_animation_walk.duplicate()
	
	_ducky.add_child(_ducky_animation_head)
	_ducky.add_child(_ducky_animation_tail)
	_ducky.add_child(_ducky_animation_wings)


func init_rotation(rotation_degrees: float):
	_ducky.rotation_degrees.y = rotation_degrees
	$CollisionShape.rotation_degrees.y = rotation_degrees
	_ducky_rotation_degrees = rotation_degrees


func init_position_and_rotation(pos: Vector3, rotation_degrees: float):
	translation = pos
	_ducky.rotation_degrees.y = rotation_degrees
	$CollisionShape.rotation_degrees.y = rotation_degrees
	_ducky_rotation_degrees = rotation_degrees


func reset_game():
	$Ducky/Armature/Skeleton/DuckyBeakBottom/Medicine.visible = false


func _process(delta):
	$SpringArm.translation = translation
	$SpringArm.translation.y += _spring_arm_offset
	


func _physics_process(delta):
	var axis := Vector3.ZERO

	if movement_enabled:
		axis.z = Input.get_axis("up", "down")
		axis.x = Input.get_axis("left", "right")

#	var forward: Vector3 = _camera.transform.basis.z
#	var right: Vector3 = _camera.transform.basis.x

#	var desired_direction := Vector2(axis.x, axis.z)
#	desired_direction = desired_direction.rotated($SpringArm.rotation.z)
#
#	print($SpringArm.rotation.y)
	
	
	
	#print("Ducky %s   Desired %s" % [_ducky.rotation.y, desired_rotation])
	
	var action1 := Input.is_action_pressed("left_click")
	var action2 := Input.is_action_pressed("right_click")
	
	var speed: float
	var walk_anim_speed: float
	var max_speed := 50.0
	if action2:
		speed = 10.0
		walk_anim_speed = 2.5
	else:
		speed = max_speed
		walk_anim_speed = 5.0


	var forward: Vector3 = _ducky.transform.basis.z
	var right: Vector3 = _ducky.transform.basis.x

	var vel := (forward * -axis.z + right * -axis.x)
	vel = vel.normalized() * speed

	if is_on_floor():
		_gravity = 0.0
	else:
		_gravity -= 90.0 * delta
#
	vel.y = _gravity
	

	
	move_and_slide(vel, Vector3.UP)
	
	
	
	var rot_speed
	if vel.z < 1.0:
		rot_speed = TAU
	else:
		rot_speed = TAU * 0.5
	
	var desired_rotation: float = _spring_arm.look_rotation_degrees.y + 180.0
	
	_ducky_rotation_degrees = rad2deg(lerp_angle(deg2rad(_ducky_rotation_degrees), deg2rad(desired_rotation), rot_speed * delta))
	_ducky.rotation_degrees.y = _ducky_rotation_degrees
	$CollisionShape.rotation_degrees.y = _ducky_rotation_degrees
	

	var moving := vel.x != 0 || vel.z != 0
	var falling := vel.y != 0
	
	if moving:
#		_ducky_animation_head.stop()
#		_ducky_animation_tail.stop()
		
		_ducky_animation_walk.playback_speed = walk_anim_speed
		if vel.z < 0.0:
			_ducky_animation_walk.play("Walk")
		else:
			_ducky_animation_walk.play_backwards("Walk")
		
		_reset_idle = true
		
	if action1:
		if !Globals.action1_active && movement_enabled:
			Globals.action1_active = true
			Globals.aim_shown = true
			owner.show_aim()
			_reset_idle = true
			_ducky_animation_head.play("BiteStart")
			_ducky_animation_head.queue("BeakOpen")
	else:
		if Globals.action1_active:
			Globals.action1_active = false
			owner.hide_aim()
			Globals.aim_shown = false
			_ducky_animation_head.play("BiteEnd")
			_ducky_animation_head.queue("BeakClosed")
			
			var screen_pos := Globals.aim_offset + Globals.aim_anchor + Vector2(64, 64)

			var from = $SpringArm/Camera.project_ray_origin(screen_pos)
			var to = from + $SpringArm/Camera.project_ray_normal(screen_pos) * 1000.0

			
			
			var space_rid = get_world().space
			var space_state = PhysicsServer.space_get_direct_state(space_rid)


			var res = space_state.intersect_ray(
				from,
				to, 
				[],
				1 << 4,
				true,
				false)

			if res.size() > 0:
				var collider = res["collider"]
				if collider.is_in_group("Medicine"):
					collider.visible = false
					var test = collider.collision_mask
					$Ducky/Armature/Skeleton/DuckyBeakBottom/Medicine.visible = true
					Globals.has_medicine = true
				elif collider.is_in_group("Snail"):
					collider.visible = false
					Globals.snail_count += 1


	
	if action2:
		if !Globals.action2_active && movement_enabled:
			Globals.action2_active = true
			_reset_idle = true
			_ducky_animation_wings.play("WingsUp")
			_idle_cooldown_flatter.restart_with(1.0 + randf() * 2)

		if _idle_cooldown_flatter.done:
			_idle_cooldown_flatter.restart_with(1.0 + randf() * 2)
			_ducky_animation_wings.play("WingsFlatter")
			
	else:
		if Globals.action2_active:
			Globals.action2_active = false
			_ducky_animation_head.play("WingsDown")
	
		
	if !moving && !action1 && !action2 && !falling:
		
		var wait_for_animations := false
		if _reset_idle:
			if (_ducky_animation_walk.is_playing() ||
				_ducky_animation_head.is_playing() ||
				_ducky_animation_tail.is_playing() ||
				_ducky_animation_wings.is_playing()):
				wait_for_animations = true

				
		if !wait_for_animations:
			if _reset_idle:
				_idle_cooldown_body.restart_with(2.0 + randf() * 5)
				_idle_cooldown_head.restart_with(2.0 + randf() * 5)
				_idle_cooldown_tail.restart_with(2.0 + randf() * 5)
				
				_ducky_animation_walk.play("RestPose")
	#
			if !_ducky_animation_walk.is_playing():
				_ducky_animation_walk.playback_speed = 1.0

				if !_idle_cooldown_body.done:
					_ducky_animation_walk.play("IdleBody1")
				else:
					_idle_cooldown_body.restart_with(randf() * 5)
					_ducky_animation_walk.play("IdleBody2")
					
			
			if !_ducky_animation_head.is_playing():
				if _idle_cooldown_head.done:
					_idle_cooldown_head.restart_with(2.0 + randf() * 5)
					
					if randf() < 0.5:
						_ducky_animation_head.play("IdleHead1")
					else:
						_ducky_animation_head.play("IdleHead2")
			
			if !_ducky_animation_tail.is_playing():
				if _idle_cooldown_tail.done:
					_idle_cooldown_tail.restart_with(2.0 + randf() * 5)

					_ducky_animation_tail.play("IdleTail")

			
			_reset_idle = false
	
	

