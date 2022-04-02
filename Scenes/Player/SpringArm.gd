extends SpringArm


var look_rotation_degrees := Vector3.ZERO

var offset := 0.0


func _ready():
	set_as_toplevel(true)
	

func _input(event):
	
	if event is InputEventMouseMotion:
		var delta: Vector2 = event.relative
		
		if !Globals.action1_active && !Globals.action2_active:
			# Dont allow turning sideways
			look_rotation_degrees.y -= delta.x
		
		
		look_rotation_degrees.x -= delta.y
		
		look_rotation_degrees.x = clamp(look_rotation_degrees.x, 315, 380)
		look_rotation_degrees.y = wrapf(look_rotation_degrees.y, -180, 180)


func _process(delta):
	if Globals.action1_active:
		offset += delta * 60
	else:
		offset -= delta * 60
	
	offset = clamp(offset, 0, 30)
		
	rotation_degrees.x = look_rotation_degrees.x
	rotation_degrees.y = look_rotation_degrees.y + offset
