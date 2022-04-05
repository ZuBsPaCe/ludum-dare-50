extends SpringArm


var look_rotation_degrees := Vector3.ZERO

var offset := 0.0

var use_last_mouse_delta := false
var last_mouse_delta := Vector2.ZERO

var smooth_mouse_delta := Vector2.ZERO


func _ready():
	set_as_toplevel(true)
	

func _input(event):
	if event is InputEventMouseMotion:
		last_mouse_delta = event.relative
		use_last_mouse_delta = true


func _process(delta):
	var target_mouse_delta := Vector2.ZERO
	if use_last_mouse_delta:
		target_mouse_delta = last_mouse_delta
		use_last_mouse_delta = false
	
	var delta_distance := target_mouse_delta.distance_to(smooth_mouse_delta)
	smooth_mouse_delta = smooth_mouse_delta.move_toward(target_mouse_delta, delta_distance * delta * 5.0)
	
	if !Globals.action1_active && !Globals.action2_active:
		# Dont allow turning sideways
		look_rotation_degrees.y -= smooth_mouse_delta.x
	
	
	look_rotation_degrees.x -= smooth_mouse_delta.y
	
	look_rotation_degrees.x = clamp(look_rotation_degrees.x, 315, 380)
	look_rotation_degrees.y = wrapf(look_rotation_degrees.y, -180, 180)
	
	if Globals.aim_shown:
		Globals.aim_offset += smooth_mouse_delta * 0.5
		Globals.aim_offset.x = clamp(Globals.aim_offset.x, -64, 64)
		Globals.aim_offset.y = clamp(Globals.aim_offset.y, -64, 64)
	
	
	
	if Globals.action1_active:
		offset += delta * 60
	else:
		offset -= delta * 60
	
	offset = clamp(offset, 0, 30)
		
	rotation_degrees.x = look_rotation_degrees.x
	rotation_degrees.y = look_rotation_degrees.y + offset
