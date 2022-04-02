extends KinematicBody

onready var _camera := $Camera

var _gravity := 0.0

func _input(event):
	if event is InputEventMouseMotion:
		var delta: Vector2 = event.relative
		_camera.rotation_degrees.y -= delta.x
		_camera.rotation_degrees.x -= delta.y


func _physics_process(delta):
	var axis := Vector3.ZERO
	
	axis.z = Input.get_axis("up", "down")
	axis.x = Input.get_axis("left", "right")
	
	var forward: Vector3 = _camera.transform.basis.z
	var right: Vector3 = _camera.transform.basis.x
	
	var vel := (forward * axis.z + right * axis.x)
	
	if is_on_floor():
		_gravity = 0.0
	else:
		_gravity -= 5.0 * delta
	
	vel.y = 0.0
	
	vel = vel.normalized() * 50.0
	move_and_slide(vel, Vector3.UP)
	
	

