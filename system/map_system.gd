extends Node2D

# --- EXPORTS & REFS ---
@export var placed_hallways_node: Node2D
@onready var straight_label = $StraightRemaining
@onready var warning = $Warning
@onready var trash_icon = $TrashIcon
@onready var sanity_label = $SanityLabel # From friend's version

# --- VARIABLES ---
var grid_size = 50
var total_hallways = 15 # Maintained your single inventory system
var dragged_hallway: Node2D = null
var placed_previews: Array = []
var selected_preview_data = null 

# --- INITIALIZATION ---
func toggle_map():
	visible = !visible
	
	if visible:
		# Check if the child reveal happened AND we haven't shown the tutorial yet
		if GameManager.has_reclaim_hallway and not GameManager.has_opened_reclaim_tutorial:
			_show_map_reclaim_dialogue()
			GameManager.has_opened_reclaim_tutorial = true # Never show again [cite: 1, 9]
		
		# Standard first-time map tutorial (if they didn't reach the child yet)
		elif not GameManager.has_opened_map:
			GameManager.has_opened_map = true
			_show_map_tutorial_dialogue()

func _show_map_tutorial_dialogue():
	var my_dialogue = load("res://dialogues/game_dialogue.dialogue")
	# Start the specific explanation section
	DialogueManager.show_dialogue_balloon(my_dialogue, "map_explanation")

func _show_map_reclaim_dialogue():
	var my_dialogue = load("res://dialogues/game_dialogue.dialogue")
	if my_dialogue:
		# Run the instruction dialogue while the map is open
		DialogueManager.show_dialogue_balloon(my_dialogue, "map_reclaim_explanation")
	
func _ready():
	visible = false
	trash_icon.hide()
	
	# Friend's Sanity Logic
	if sanity_label:
		$SanityLabel.text = "Sanity: %d" % GameManager.sanity
	GameManager.sanity_changed.connect(_on_sanity_changed)
	
	# Selection/Trash Setup
	trash_icon.pressed.connect(_on_trash_button_pressed)
	trash_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Button Connections (Your manual UI setup)
	var straight_btn = $Panel2/StraightHallway
	var turn_btn = $Panel2/TurnHallway
	if straight_btn: straight_btn.pressed.connect(_on_straight_clicked)
	if turn_btn: turn_btn.pressed.connect(_on_turn_clicked)
	
	_update_inventory_ui()

func _on_sanity_changed(value: int):
	if sanity_label:
		$SanityLabel.text = "Sanity: %d" % value

# --- LOOP ---
func _process(_delta):
	# Only run logic if map is open and dragging
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
	toggle_map()
	visible = true
	_update_inventory_ui()
	if sanity_label:
		$SanityLabel.text = "Sanity: %d" % GameManager.sanity

func close_map():
	visible = false
	trash_icon.hide()
	_spawn_real_hallways()
	# Optional: disconnect sanity here if you want it to ONLY update while map is open
	# if GameManager.sanity_changed.is_connected(_on_sanity_changed):
	# 	GameManager.sanity_changed.disconnect(_on_sanity_changed)

# --- INPUT HANDLING ---
func _input(event):
	if !visible: return

	# UI Blocking (Friend's logic was slightly different, but this prevents click-through)
	if event is InputEventMouseButton and event.pressed:
		if $Panel2.get_global_rect().has_point(get_global_mouse_position()):
			return

	# Single Inventory Placement Check
	if event.is_action_pressed("place_straight") or event.is_action_pressed("place_turn"):
		var type = "straight" if event.is_action_pressed("place_straight") else "turn"
		_try_start_drag(type)

	# Selection Logic
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !dragged_hallway:
			_handle_selection(get_global_mouse_position())

	# Active Dragging
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

# --- SELECTION & DELETION ---
func _handle_selection(click_pos: Vector2):
	var clicked_grid = (click_pos / grid_size).floor()
	var found = false
	
	for p in placed_previews:
		if p.grid_pos == clicked_grid:
			selected_preview_data = p
			trash_icon.global_position = (p.grid_pos * grid_size) + Vector2(10, 10) 
			trash_icon.show()
			found = true
			break
	
	if !found:
		trash_icon.hide()
		selected_preview_data = null

func _on_trash_button_pressed():
	if selected_preview_data:
		if _is_player_in_cell(selected_preview_data.grid_pos):
			_show_warning("Cannot remove: Player inside!")
			trash_icon.hide()
			selected_preview_data = null
			return

		# Refund to the single pool
		total_hallways += 1
		
		selected_preview_data.visual_node.queue_free()
		placed_previews.erase(selected_preview_data)
		
		trash_icon.hide()
		selected_preview_data = null
		_update_inventory_ui()

func _is_player_in_cell(cell_coords: Vector2) -> bool:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var player_grid_pos = (player.global_position / grid_size).floor()
		return player_grid_pos == cell_coords
	return false

# --- CORE LOGIC ---
func _can_place_here() -> bool:
	if !dragged_hallway: return false
	var current_grid_pos = (dragged_hallway.global_position / grid_size).floor()
	for p in placed_previews:
		if p.grid_pos == current_grid_pos: return false
	return true

func _try_start_drag(type: String):
	if total_hallways > 0:
		_start_drag(type)
	else:
		_show_warning("No hallways left!")

func _start_drag(type: String):
	trash_icon.hide()
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

func _show_warning(message: String):
	if warning:
		warning.text = message
		warning.modulate = Color.RED 
		warning.show()
		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(warning):
			var tween = create_tween()
			tween.tween_property(warning, "modulate:a", 0.0, 0.5)
			await tween.finished
			warning.text = ""
			warning.hide()
			warning.modulate.a = 1.0

func _cancel_drag():
	if dragged_hallway:
		dragged_hallway.queue_free()
		dragged_hallway = null

func _on_straight_clicked():
	_try_start_drag("straight")

func _on_turn_clicked():
	_try_start_drag("turn")
