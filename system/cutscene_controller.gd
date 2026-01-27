extends Node

@onready var player = get_node("../Player")
@onready var child = get_node("../Child")
@onready var child_sprite = get_node("../Child/AnimatedSprite2D")
@onready var cutscene_camera = get_node("../CutsceneCamera")
@onready var player_camera = player.get_node("Camera2D")
@onready var wake_text = get_node("../../CanvasLayer/WakeText")
@onready var wake_panel = get_node("../../CanvasLayer/Panel")
@onready var vignette = get_node("../../CanvasLayer/Vignette")
@onready var audio_player = get_node("../../CanvasLayer/DoorPlayer") # AudioStreamPlayer node
var follow_child = false
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
