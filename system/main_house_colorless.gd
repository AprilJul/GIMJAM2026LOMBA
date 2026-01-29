extends Node2D

# --- EXISTING REFERENCES ---
@onready var player_cam = $WorldContent/Player/Camera2D
@onready var map_cam = $MapCanvas/MapCamera
@onready var map_system = $MapCanvas/MapSystem
@onready var grid_display = $WorldContent/GridDisplay
@onready var player = $WorldContent/Player
@onready var player_hud = $PlayerHUD

# --- NEW STAIRS REFERENCES ---
# Drag these from the scene tree to the Inspector slots
@export var f1_landing: Marker2D
@export var f2_landing: Marker2D
@export var stairs_up_trigger: Area2D
@export var stairs_down_trigger: Area2D

func _ready():
	print("Main house added to group: ", is_in_group("main_house"))
	map_system.visible = false
	map_cam.enabled = false 
	player_cam.enabled = true 
	
	add_to_group("main_house")
	# Connect the teleport signals
	if stairs_up_trigger:
		stairs_up_trigger.body_entered.connect(_on_stairs_up_entered)
	if stairs_down_trigger:
		stairs_down_trigger.body_entered.connect(_on_stairs_down_entered)

	# --- NEW: Spawn player in Bedroom1 and start cutscene ---
	var player_spawn = get_node("WorldContent/Rooms/Floor2/Bedroom1/PlayerSpawn") 
	player.global_position = player_spawn.global_position 
	
	var child = get_node("WorldContent/Child") 
	var child_spawn = get_node("WorldContent/Rooms/Floor2/Bedroom1/ChildSpawn") 
	child.global_position = child_spawn.global_position
	
	var cutscene = get_node("WorldContent/CutsceneController")
	cutscene.play_cutscene("bedroom_cutscene_1")


func _input(event):
	if event.is_action_pressed("toggle_map"):
		# Let the map system decide its own state first
		map_system.toggle_map()
		
		# Now sync everything else to whatever the map system just did
		var opening = map_system.visible
		grid_display.visible = opening
		
		map_cam.enabled = opening
		player_cam.enabled = !opening
		
		if opening:
			map_cam.make_current()
			map_system.open_map()
		else:
			player_cam.make_current()
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

# --- TOGGLE MAP FROM HUD ---
func toggle_map_from_hud():
	# Replikasi logika dari _input()
	map_system.toggle_map()
	
	var opening = map_system.visible
	grid_display.visible = opening
	
	map_cam.enabled = opening
	player_cam.enabled = !opening
	
	if opening:
		map_cam.make_current()
		map_system.open_map()
		# --- TAMBAHKAN: Sembunyikan HUD saat map terbuka ---
		if player_hud and player_hud.has_method("toggle_hud_visibility"):
			player_hud.toggle_hud_visibility(true)
		elif player_hud:
			# Fallback jika method tidak ada
			player_hud.visible = false
	else:
		player_cam.make_current()
		map_system.close_map()
		if player_hud and player_hud.has_method("toggle_hud_visibility"):
			player_hud.toggle_hud_visibility(false)
		elif player_hud:
			# Fallback jika method tidak ada
			player_hud.visible = true
