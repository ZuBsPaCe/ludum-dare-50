extends Node


var _center_node: Node2D;



var action1_active := false
var action2_active := false

#960 + 192 = 1152. Max range 64. => 1088 -> 1216
var aim_anchor := Vector2(1920, 1080) * 0.5 - Vector2(64, 64) + Vector2(192, 0.0)
var aim_offset := Vector2.ZERO
var aim_shown := false

var has_medicine := false
var snail_count := 0
var flower_count := 0

var player_near_lady := false


func _ready():
	_center_node = Node2D.new()
	add_child(_center_node)



func reset_game():
	has_medicine = false
	snail_count = 0
	flower_count = 0
	player_near_lady = false


func setup():
	pass



#
#func shake(dir: Vector2) -> void:
#	camera.start_shake(dir, 0.5, 20, 0.15)
#
#func get_global_mouse_position() -> Vector2:
#	return _center_node.get_global_mouse_position()
#
