extends Node2D

@export var placed_hallways_node: Node2D
@onready var straight_label = $StraightRemaining
@onready var warning = $Warning
@onready var trash_icon = $TrashIcon # The Button we just created

var grid_size = 50
var total_hallways = 10 # Communal count
var dragged_hallway: Node2D = null
var placed_previews: Array = []
var selected_preview_data = null 

func _ready():
	visible = false
	trash_icon.hide()
	
	# Connect the professional cleanup signal
	trash_icon.pressed.connect(_on_trash_button_pressed)
	
	# Styling the trash icon (Professional touch)
	trash_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_update_inventory_ui()
	
	# 1. Get references to your buttons based on the screenshot tree
	var straight_btn = $Panel2/StraightHallway
	var turn_btn = $Panel2/TurnHallway

	# 2. Connect them. We use 'pressed' so it triggers on click.
	if straight_btn:
		straight_btn.pressed.connect(_on_straight_clicked)
	if turn_btn:
		turn_btn.pressed.connect(_on_turn_clicked)
	
func _process(_delta):
	if visible and dragged_hallway:
		var mouse_pos = get_global_mouse_position()
		var grid_pos = (mouse_pos / grid_size).floor()
		dragged_hallway.global_position = (grid_pos * grid_size) + Vector2(grid_size / 2, grid_size / 2)
		dragged_hallway.scale = Vector2.ONE
		
		if _can_place_here():
			dragged_hallway.modulate = Color(1, 1, 1, 0.7)
		else:
			dragged_hallway.modulate = Color(1, 0, 0, 0.8)

# --- MAP CONTROL ---
func open_map():
	visible = true
	_update_inventory_ui()

func close_map():
	visible = false
	trash_icon.hide()
	_spawn_real_hallways()

func _input(event):
	if !visible: return

	if event is InputEventMouseButton and event.pressed:
		# If the mouse is over Panel2 (where your buttons are), ignore the click for the grid
		if $Panel2.get_global_rect().has_point(get_global_mouse_position()):
			return
	# Placement Logic
	if event.is_action_pressed("place_straight") or event.is_action_pressed("place_turn"):
		if total_hallways > 0:
			var type = "straight" if event.is_action_pressed("place_straight") else "turn"
			_start_drag(type)
		else:
			_show_warning("No hallways left!")

	# Professional Interaction: Clicking a hallway to delete it
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !dragged_hallway:
			_handle_selection(get_global_mouse_position())

	if dragged_hallway:
		if event.is_action_pressed("rotate_left"): dragged_hallway.rotate_left()
		if event.is_action_pressed("rotate_right"): dragged_hallway.rotate_right()
		
		if event.is_action_pressed("place_hall"):
			if _can_place_here():
				_place_preview()
				_cancel_drag()
			else:
				_show_warning("Space Occupied!")
				
		if event.is_action_pressed("cancel_hall"):
			_cancel_drag()

# --- THE FEATURE: SELECTION & DELETION ---

func _handle_selection(click_pos: Vector2):
	var clicked_grid = (click_pos / grid_size).floor()
	var found = false
	
	for p in placed_previews:
		if p.grid_pos == clicked_grid:
			selected_preview_data = p
			# Position the UI button exactly over the hallway
			# We offset by -20 (half of icon size) to center it
			trash_icon.global_position = (p.grid_pos * grid_size) + Vector2(10, 10) 
			trash_icon.show()
			found = true
			break
	
	if !found:
		trash_icon.hide()
		selected_preview_data = null

# --- MODIFIED REFUND LOGIC ---
func _on_trash_button_pressed():
	if selected_preview_data:
		# 1. Check if player is in this specific hallway
		if _is_player_in_cell(selected_preview_data.grid_pos):
			_show_warning("Cannot remove: Player inside!")
			trash_icon.hide()
			selected_preview_data = null
			return

		# 2. If clear, proceed with removal
		selected_preview_data.visual_node.queue_free()
		placed_previews.erase(selected_preview_data)
		
		# Refund
		total_hallways += 1
		
		trash_icon.hide()
		selected_preview_data = null
		_update_inventory_ui()

# --- NEW HELPER FUNCTION ---
func _is_player_in_cell(cell_coords: Vector2) -> bool:
	# Replace "Player" with the actual name of your player node or use a Group
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		# Convert player's world position to the same grid system the map uses
		var player_grid_pos = (player.global_position / grid_size).floor()
		
		# If the player's grid position matches the hallway's grid position
		return player_grid_pos == cell_coords
	
	return false

# --- CORE LOGIC (PREVIOUS SYSTEM) ---

func _can_place_here() -> bool:
	if !dragged_hallway: return false
	var current_grid_pos = (dragged_hallway.global_position / grid_size).floor()
	for p in placed_previews:
		if p.grid_pos == current_grid_pos: return false
	return true

func _start_drag(type: String):
	trash_icon.hide() # Hide trash if we start placing something new
	if dragged_hallway: _cancel_drag()
	
	var preview_scene = preload("res://rooms/hallways/hallway_preview.tscn")
	var preview = preview_scene.instantiate()
	preview.type = type
	dragged_hallway = preview
	
	var sprite = dragged_hallway.get_node_or_null("Sprite2D")
	if sprite:
		var tex_path = "res://assets/colorless/hallway_" + type + ".png"
		sprite.texture = load(tex_path)
	
	add_child(dragged_hallway)

func _place_preview():
	var current_pos = dragged_hallway.global_position
	var grid_pos = (current_pos / grid_size).floor()
	
	var map_visual = dragged_hallway.duplicate()
	map_visual.modulate = Color(1, 1, 1, 1)
	add_child(map_visual)
	map_visual.global_position = current_pos
	
	placed_previews.append({
		"type": dragged_hallway.type,
		"grid_pos": grid_pos,
		"rotation": dragged_hallway.current_rotation_index if "current_rotation_index" in dragged_hallway else 0,
		"visual_node": map_visual
	})
	
	total_hallways -= 1
	_update_inventory_ui()

func _spawn_real_hallways():
	if !is_instance_valid(placed_hallways_node):
		push_error("Godot Help: placed_hallways_node is MISSING!")
		return
	
	for child in placed_hallways_node.get_children():
		child.queue_free()

	for p in placed_previews:
		var path = ""
		if p.type == "straight":
			path = "res://rooms/hallways/hallway_straight_horizontal.tscn" if (p.rotation % 2 == 0) else "res://rooms/hallways/hallway_straight_vertical.tscn"
		else:
			path = "res://rooms/hallways/hallway_turn.tscn"
		
		if ResourceLoader.exists(path):
			var instance = load(path).instantiate()
			instance.position = p.grid_pos * grid_size + Vector2(grid_size / 2, grid_size / 2)
			if p.type == "turn": instance.rotation_degrees = p.rotation * 90
			placed_hallways_node.add_child(instance)

func _update_inventory_ui():
	if straight_label:
		straight_label.text = "Available: " + str(total_hallways)
		straight_label.modulate = Color.WHITE

func _show_warning(message: String):
	if warning:
		# 1. Set the content and the color to Red
		warning.text = message
		warning.modulate = Color.RED 
		warning.show()
		
		# 2. Wait for the player to read it
		await get_tree().create_timer(2.0).timeout
		
		# 3. Double-check the node is still there (prevents crash on scene change)
		if is_instance_valid(warning):
			# Use a Tween for a professional "fade away"
			var tween = create_tween()
			tween.tween_property(warning, "modulate:a", 0.0, 0.5)
			
			await tween.finished
			# 4. Cleanup so it's ready for the next warning
			warning.text = ""
			warning.hide()

func _cancel_drag():
	if dragged_hallway:
		dragged_hallway.queue_free()
		dragged_hallway = null

func _on_straight_clicked():
	print("UI: Straight Button Pressed") # Check your console for this!
	_start_drag("straight")

func _on_turn_clicked():
	print("UI: Turn Button Pressed")
	_start_drag("turn")
	
