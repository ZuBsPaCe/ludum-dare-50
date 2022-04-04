extends Spatial

var start := Vector3.ZERO
var target := Vector3.ZERO

func _ready():
	start = transform.origin
	update_target()
	
	$AnimationPlayer.get_animation("Slime").loop = true
	$AnimationPlayer.play("Slime")

func _process(delta):
	
	var vec = (target - transform.origin).normalized()
	transform.origin += vec * 2.0 * delta
	
	if transform.origin.distance_to(target) < 1.0:
		update_target()

func update_target():
	target.x = start.x + 40 * randf() - 20
	target.z = start.z + 20 * randf() - 10
	target.y = start.y
		
	

