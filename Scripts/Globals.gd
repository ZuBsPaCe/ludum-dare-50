extends Node


var _center_node: Node2D;



var action1_active := false
var action2_active := false


func _ready():
	_center_node = Node2D.new()
	add_child(_center_node)



func reset_game():
	pass


func setup():
	pass



#
#func shake(dir: Vector2) -> void:
#	camera.start_shake(dir, 0.5, 20, 0.15)
#
#func get_global_mouse_position() -> Vector2:
#	return _center_node.get_global_mouse_position()
#
