extends Node2D

@export var placed_hallways_node: Node2D
@onready var straight_label = $StraightRemaining

var grid_size = 50
var inventory = {"straight": 5, "turn": 2}
var dragged_hallway: Node2D = null
var placed_previews: Array = []

func _ready():
	visible = false
	_update_inventory_ui()

func _process(_delta):
	# Only run logic if the Map is actually open
	if visible and dragged_hallway:
		# FIX: This maps the screen click to the actual world coordinates
		var mouse_pos = get_global_mouse_position()
		var grid_pos = (mouse_pos / grid_size).floor()
		
		# Snapping to grid center: (X * 50 + 25, Y * 50 + 25)
		dragged_hallway.global_position = (grid_pos * grid_size) + Vector2(grid_size / 2, grid_size / 2)
		
		# FIX: Prevents the hallway from shrinking when the Map Camera is zoomed out
		dragged_hallway.scale = Vector2.ONE
		
		# Color feedback based on occupation
		if _can_place_here():
			dragged_hallway.modulate = Color(1, 1, 1, 0.7) # Ghostly white
		else:
			dragged_hallway.modulate = Color(1, 0, 0, 0.8) # Warning red

func open_map():
	visible = true
	_update_inventory_ui()

func close_map():
	visible = false
	_spawn_real_hallways()

func _input(event):
	if !visible:
		return

	# Start dragging a hallway
	if event.is_action_pressed("place_straight"):
		if inventory["straight"] > 0:
			_start_drag("straight")
		else:
			_show_warning("No straights left!")

	if event.is_action_pressed("place_turn"): # Define this in Input Map
		if inventory["turn"] > 0:
			_start_drag("turn")
			
	if dragged_hallway:
		# Rotation Logic
		if event.is_action_pressed("rotate_left"):
			dragged_hallway.rotate_left()
		if event.is_action_pressed("rotate_right"):
			dragged_hallway.rotate_right()

		# Final Placement (Pressing Enter/Space)
		if event.is_action_pressed("place_hall"):
			if _can_place_here():
				_place_preview()
				_cancel_drag()
			else:
				_show_warning("Space Occupied!")

		# Cancel current drag
		if event.is_action_pressed("cancel_hall"):
			_cancel_drag()
		

func _can_place_here() -> bool:
	if !dragged_hallway: return false
	var current_grid_pos = (dragged_hallway.global_position / grid_size).floor()
	for p in placed_previews:
		if p.grid_pos == current_grid_pos:
			return false
	return true

func _start_drag(type: String):
	if dragged_hallway:
		_cancel_drag()
	
	var preview_scene = preload("res://rooms/hallways/hallway_preview.tscn")
	var preview = preview_scene.instantiate()
	preview.type = type
	dragged_hallway = preview
	
	var sprite = dragged_hallway.get_node_or_null("Sprite2D")
	if sprite:
		if type == "straight":
			sprite.texture = load("res://assets/colorless/hallway_straight.png")
		elif type == "turn":
			# Ensure this path matches your friend's art folder structure
			sprite.texture = load("res://assets/colorless/hallway_turn.png")
	
	add_child(dragged_hallway)

func _place_preview():
	var current_pos = dragged_hallway.global_position
	var grid_pos = (current_pos / grid_size).floor()
	var current_type = dragged_hallway.type
	var current_rot = dragged_hallway.current_rotation_index if "current_rotation_index" in dragged_hallway else 0
	
	# Create the visual "sticker" that stays on the Map UI
	var map_visual = dragged_hallway.duplicate()
	map_visual.modulate = Color(1, 1, 1, 1)
	add_child(map_visual)
	map_visual.global_position = current_pos
	
	# Store the data for spawning real hallways later
	var data = {
		"type": current_type,
		"grid_pos": grid_pos,
		"rotation": current_rot,
		"visual_node": map_visual
	}
	placed_previews.append(data)
	
	inventory[current_type] -= 1
	_update_inventory_ui()

func _spawn_real_hallways():
	if !placed_hallways_node:
		return
	
	# Clear old hallways to prevent overlapping
	for child in placed_hallways_node.get_children():
		child.queue_free()

	for p in placed_previews:
		var path = ""
		var final_rotation = 0
		
		if p.type == "straight":
			# Determine file path based on rotation index
			if p.rotation == 0 or p.rotation == 2:
				path = "res://rooms/hallways/hallway_straight_horizontal.tscn"
			else:
				path = "res://rooms/hallways/hallway_straight_vertical.tscn"
			
			# FIX: Do NOT rotate straights further, the file is already correct.
			# Exception: If p.rotation is 2 (180 deg), you might want to flip it, 
			# but for a straight hallway, it usually looks the same.
			final_rotation = 0 
			
		elif p.type == "turn":
			path = "res://rooms/hallways/hallway_turn.tscn"
			# Turns NEED the rotation index applied to face the right corner
			final_rotation = p.rotation * 90
		
		if ResourceLoader.exists(path):
			var instance = load(path).instantiate()
			
			# Set position based on grid center
			instance.position = p.grid_pos * grid_size + Vector2(grid_size / 2, grid_size / 2)
			
			# Apply the corrected rotation
			instance.rotation_degrees = final_rotation
			
			placed_hallways_node.add_child(instance)
		else:
			print("Missing file: ", path)

func _update_inventory_ui():
	if straight_label:
		straight_label.text = "Straights: " + str(inventory["straight"])
		straight_label.modulate = Color(1, 1, 1)

func _show_warning(message: String):
	if straight_label:
		straight_label.text = message
		straight_label.modulate = Color(1, 0, 0)
		await get_tree().create_timer(1.5).timeout
		_update_inventory_ui()

func _cancel_drag():
	if dragged_hallway:
		dragged_hallway.queue_free()
		dragged_hallway = null
