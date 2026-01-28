extends Node

@onready var player = get_node("../Player")
@onready var child = get_node("../Child")
@onready var player_sprite = get_node("../Player/AnimatedSprite2D")
@onready var child_sprite = get_node("../Child/AnimatedSprite2D")
@onready var cutscene_camera = get_node("../CutsceneCamera")
@onready var player_camera = player.get_node("Camera2D")
@onready var wake_text = get_node("../../CanvasLayer/WakeText")
@onready var wake_panel = get_node("../../CanvasLayer/Panel")
@onready var vignette = get_node("../../CanvasLayer/Vignette")
@onready var audio_player = get_node("../../CanvasLayer/DoorPlayer") # AudioStreamPlayer node

@onready var aa = "bb"
var follow_child = false
const INSTRUCTION_POPUP = preload("res://instruction/InstructionPopup.tscn")

# Item obtained animation preload
const ITEM_GET_UI = preload("res://player/inventory/items/item_get_ui.tscn")
# Memmory shard inventory initiation
const ITEM_TEDDY = preload("res://player/inventory/items/mem_shard/teddy_bear.tres")

func spawn_instruction():
	# 1. Buat instansi dari scene
	var popup = INSTRUCTION_POPUP.instantiate()
	
	# 2. Isi data antrian (queue) teks dan gambar
	# Pastikan path gambar 'res://...' sudah benar sesuai folder kamu
	popup.queue = [
		{
			"text": "Press WASD to move around", 
			"image": preload("res://art/UI/wasd.png")
		},
	]
	
	# 3. Tentukan posisi munculnya (di atas kepala player)
	# Kita gunakan global_position agar posisinya akurat di map
	popup.position = Vector2(0, -30)
	
	# 4. Tambahkan ke scene utama (Parent dari player)
	# Alasan: Agar jika player berbalik (flip), teksnya tidak ikut terbalik
	add_child(popup)
	
func _run_dialogue(title: String):
	var my_dialogue = load("res://dialogues/game_dialogue.dialogue")
	if my_dialogue:
		GameManager.is_dialog_active = true
		
		# We capture the actual balloon (UI) created
		var balloon = DialogueManager.show_dialogue_balloon(my_dialogue, title)
		
		# If for some reason the balloon failed to create, don't hang the game
		if balloon:
			await balloon.tree_exited 
		
		GameManager.is_dialog_active = false
	else:
		print("Dialogue file not found!")

func play_cutscene(name: String):
	match name:
		"bedroom_cutscene_1":
			await _play_bedroom_cutscene_1()
		"tutorial_glitch":
			await _play_tutorial_glitch()
		"interaction_teddy":
			await _play_interaction_teddy_cutscene()
		"show_child_location":
			await _play_show_child_location()
			
func _play_bedroom_cutscene_1() -> void:
	# 1. Disable player control
		
	player.rotation = -1.57
	player.global_position += Vector2(5, -20)
	player.can_move = false
	print("Act 1: Player control disabled.")

	# 2. Switch to CutsceneCamera and center on Player
	_switch_to_cutscene_camera()
	cutscene_camera.global_position = player.global_position
	print("Act 2: Cutscene camera centered on player.")

	# 2b. EXTREME zoom on player
	cutscene_camera.zoom = Vector2(14, 14)
	wake_panel.visible = true
	wake_text.text = "Zzz"
	await get_tree().create_timer(1.0).timeout
	wake_text.text = "zZz"
	await get_tree().create_timer(1.0).timeout
	wake_text.text = "zzZ"
	await get_tree().create_timer(1.0).timeout
	wake_text.text = "Zzz"
	await get_tree().create_timer(2.0).timeout
	# --- Play audio while zoom happens ---
	print(audio_player)
	audio_player.play()
	print("Act 3: Audio started while zooming on player.")
	print("Act 3b: Extreme zoom finished.")

	# 4. Wait 3 seconds, then child runs to door
	await get_tree().create_timer(1.5).timeout
	
	wake_panel.visible = false
	wake_text.visible = false
	
	var door = get_node("../Rooms/Floor2/Bedroom1/DoorDirection")
	
	follow_child = true   # enable camera follow
	child_sprite.play("idle")
	await get_tree().create_timer(0.5).timeout
	child_sprite.play("walk_right")
	var child_tween = create_tween()
	child_tween.tween_property(child, "global_position", door.global_position, 1.5)
	print("child moved")
	await child_tween.finished
	
	print("Act 4: Child ran to door.")

	# 5. Child disappears
	child.visible = false
	child.global_position = Vector2(3000, 0)
	follow_child = false  # stop following
	print("Act 5: Child disappeared.")

	# 6. Camera sticks around for ~1.2s before reset
	await get_tree().create_timer(1.2).timeout
	print("Act 6: Camera held position after child vanished.")

	# 7. Reset zoom
	var reset_tween = create_tween()
	reset_tween.tween_property(cutscene_camera, "zoom", Vector2(3, 3), 0.5)
	await reset_tween.finished
	print("Act 7: Camera zoom reset.")

	# 8. Switch back to PlayerCamera
	_switch_to_player_camera()
	print("Act 8: Player camera reactivated.")
	
	await get_tree().create_timer(0.50).timeout
	wake_text.position = Vector2(680, 320)
	wake_panel.position = Vector2(680, 320)
	wake_panel.visible = true
	wake_text.visible = true
	wake_text.text = "!!!"
	await get_tree().create_timer(0.6).timeout
	# 9. Re-enable player control
	wake_text.visible = false
	wake_panel.visible = false 
	await get_tree().create_timer(3.0).timeout
	player.rotation = 0
	
	var v_tween = create_tween()
	# Fades the alpha to 0 over 1 second
	v_tween.tween_property(vignette, "modulate:a", 0.0, 1.0)
	await v_tween.finished
	vignette.visible = false
	# start dialogua
	await _run_dialogue("waking_up")
	if player.has_method("spawn_instruction"):
		player.spawn_instruction()
	player.can_move = true
	print("Act 9: Player control restored.")
	
# --- Camera Switching Helpers ---
func _switch_to_cutscene_camera():
	cutscene_camera.enabled = true
	cutscene_camera.make_current()

func _switch_to_player_camera():
	player_camera.enabled = true
	player_camera.make_current()

func _process(delta):
	# Keep cutscene camera centered on child while active
	if cutscene_camera.is_current() and follow_child and child.visible:
		cutscene_camera.global_position = child.global_position

func _play_tutorial_glitch():
	await _run_dialogue("tutorial_glitch")

func _play_show_child_location() -> void:
	var bedroom = get_node("../Rooms/Floor2/Bedroom2")
	var child_spawn = bedroom.get_node("ChildSpawn")
	child_sprite.play("idle")
	child_sprite.frame = 0
	child_sprite.pause()
	
	if not child_spawn:
		return

	# 0. Setup
	player.can_move = false
	child.global_position = child_spawn.global_position
	
	child.visible = true
	player_sprite.play("idle")
	player_sprite.frame = 1
	player_sprite.pause()
	# 1. Start at player position
	cutscene_camera.global_position = player.global_position
	cutscene_camera.zoom = Vector2(3, 3) # Match standard zoom
	_switch_to_cutscene_camera()
	
	# 2. Pan to child
	var pan_tween = create_tween().set_parallel(true)
	pan_tween.tween_property(cutscene_camera, "global_position", child.global_position, 1.5)\
		.set_trans(Tween.TRANS_SINE)
	# Zoom in slightly during the pan for dramatic effect
	pan_tween.tween_property(cutscene_camera, "zoom", Vector2(5, 5), 1.5)
	await pan_tween.finished
	
	# --- Dramatic Shake Effect ---
	var shake_tween = create_tween()
	for i in range(6):
		var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		shake_tween.tween_property(cutscene_camera, "offset", shake_offset, 0.05)
	shake_tween.tween_property(cutscene_camera, "offset", Vector2.ZERO, 0.05)
	
	# 3. Wait for the reveal to sink in
	await get_tree().create_timer(2.0).timeout
	
	# 4. Return to player
	var return_tween = create_tween().set_parallel(true)
	return_tween.tween_property(cutscene_camera, "global_position", player.global_position, 1.0)\
		.set_trans(Tween.TRANS_QUAD)
	return_tween.tween_property(cutscene_camera, "zoom", Vector2(3, 3), 1.0)
	await return_tween.finished
	
	# 5. Cleanup
	_switch_to_player_camera()
	
	await _run_dialogue("map_reclaim_opening")
	player_sprite.play("idle")
	GameManager.has_reclaim_hallway = true
	player.can_move = true
	
func _play_interaction_teddy_cutscene() -> void:
	# Reference to the Bedroom2 container where your markers are located
	var bedroom = get_node("../Rooms/Floor2/Bedroom2")
	
	# === INITIALIZATION ===
	# Ensure child is at the spawn point before anything happens
	var child_spawn = bedroom.get_node("ChildSpawn")
	if child_spawn:
		child.global_position = child_spawn.global_position
		child.visible = true
	
	# === SCENE 5A: MC ENTER & REACTION ===
	player.can_move = false
	player_sprite.play("idle")
	player_sprite.frame = 3
	player_sprite.pause()
	
	# 1. Player reacts ("...")
	await _run_dialogue("teddy_interact") 
	
	# 2. Player WALKS to PlayerStop marker
	var player_stop = bedroom.get_node("PlayerStop")
	if player_stop:
		var walk_tween = create_tween()
		if player.has_node("AnimatedSprite2D"):
			player.get_node("AnimatedSprite2D").play("walk_right")
			
		walk_tween.tween_property(player, "global_position", player_stop.global_position, 1.5)
		await walk_tween.finished
		
		if player.has_node("AnimatedSprite2D"):
			player.get_node("AnimatedSprite2D").play("idle")
			player_sprite.frame = 1
			player_sprite.pause()

	# === INTERACT: TEDDY BEAR ===
	# 3. MC thoughts ("it feels familiar...")
	await _run_dialogue("scene5A_interact_TeddyBear") 
	
	# New item animation 
	var get_ui = ITEM_GET_UI.instantiate()
	get_tree().root.add_child(get_ui)
	
	var player_screen_pos = player.get_global_transform_with_canvas().origin
	
	await get_ui.play_get_animation(ITEM_TEDDY.texture, player_screen_pos)
	
	# Adding memmory shard to the inventory
	if player.has_method("collect"):
		player.collect(ITEM_TEDDY)
		print("Debug: Teddy Bear telah dimasukkan ke inventory setelah cutscene.")
		
	# Correct variable name for GameManager
	GameManager.has_interact_teddy = true 
	GameManager.memory_shards += 1
	
	# Wait for beat before child speaks
	await get_tree().create_timer(2.0).timeout
	var child_stop = bedroom.get_node("ChildStopInt")
	if child_stop:
		var child_tween = create_tween()
		child_sprite.play("walk_up")
		child_tween.tween_property(child, "global_position", child_stop.global_position, 1.0)
		await child_tween.finished
		child_sprite.play("idle")
		
	# === SCENE 5B: TRANSITION ===
	# 4. Child is initially idle at spawn/initial position
	child_sprite.play("idle") 
	await _run_dialogue("scene5B_child")
	player_sprite.play("walk_right")
	player_sprite.frame = 2
	player_sprite.pause()
	
	# 5. Child WALKS to the ChildStopInt marker (NOT player position)

	# === AUTO MOVE: CHILD EXITS ALONE ===
	# 6. Child walks UP to DoorExit while the Player stays in position
	var door_exit = bedroom.get_node("DoorExit")
	if door_exit:
		var exit_pos = door_exit.global_position
		var child_exit_tween = create_tween()
		
		child_sprite.play("walk_front")
		child_exit_tween.tween_property(child, "global_position", exit_pos, 1.5)
		
		# Wait for child to reach the door
		await child_exit_tween.finished

	# 7. Child vanishes (TP's away)
	child.visible = false
	

	# 8. Cleanup: Scene ends, Player can move again
	player.can_move = true
