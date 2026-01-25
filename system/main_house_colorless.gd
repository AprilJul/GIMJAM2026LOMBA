extends Node2D

@onready var player_cam = $WorldContent/Player/Camera2D
@onready var map_cam = $MapCanvas/MapCamera
@onready var map_system = $MapCanvas/MapSystem
@onready var grid_display = $WorldContent/GridDisplay

func _ready():
	map_system.visible = false
	map_cam.enabled = false # Map camera starts off
	player_cam.enabled = true # Player camera starts on

func _input(event):
	if event.is_action_pressed("toggle_map"):
		var opening = !map_system.visible
		
		map_system.visible = opening
		grid_display.visible = opening
		
		# Switch Cameras
		map_cam.enabled = opening
		player_cam.enabled = !opening
		
		if opening:
			map_system.open_map()
		else:
			map_system.close_map()
