extends Node2D

# --- EXISTING REFERENCES ---
@onready var player_cam = $WorldContent/Player/Camera2D
@onready var map_cam = $MapCanvas/MapCamera
@onready var map_system = $MapCanvas/MapSystem
@onready var grid_display = $WorldContent/GridDisplay
@onready var player = $WorldContent/Player

# --- NEW STAIRS REFERENCES ---
# Drag these from the scene tree to the Inspector slots
@export var f1_landing: Marker2D
@export var f2_landing: Marker2D
@export var stairs_up_trigger: Area2D
@export var stairs_down_trigger: Area2D

func _ready():
	map_system.visible = false
	map_cam.enabled = false 
	player_cam.enabled = true 
	
	# Connect the teleport signals
	if stairs_up_trigger:
		stairs_up_trigger.body_entered.connect(_on_stairs_up_entered)
	if stairs_down_trigger:
		stairs_down_trigger.body_entered.connect(_on_stairs_down_entered)

func _input(event):
	if event.is_action_pressed("toggle_map"):
		var opening = !map_system.visible
		map_system.visible = opening
		grid_display.visible = opening
		
		map_cam.enabled = opening
		player_cam.enabled = !opening
		
		if opening:
			map_system.open_map()
		else:
			map_system.close_map()

# --- TELEPORT LOGIC ---

func _on_stairs_up_entered(body):
	if body.is_in_group("Player"):
		_teleport_player(f2_landing.global_position)

func _on_stairs_down_entered(body):
	if body.is_in_group("Player"):
		_teleport_player(f1_landing.global_position)

func _teleport_player(dest: Vector2):
	# 1. Move the player
	player.global_position = dest
	
	# 2. IMPORTANT: Reset camera smoothing 
	# This stops the camera from "flying" across the empty space between floors
	if player_cam:
		player_cam.reset_smoothing()
