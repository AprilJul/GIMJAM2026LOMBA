extends Node2D

var type: String = "straight"
var current_rotation_index: int = 0

func rotate_left():
	current_rotation_index = wrapi(current_rotation_index - 1, 0, 4)
	rotation_degrees = current_rotation_index * 90

func rotate_right():
	current_rotation_index = wrapi(current_rotation_index + 1, 0, 4)
	rotation_degrees = current_rotation_index * 90
