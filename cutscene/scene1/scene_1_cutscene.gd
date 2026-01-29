extends Node2D

@export var intro_video: VideoStream
@export var loop_video: VideoStream
@export var sound_effect: AudioStream
@export var dialogue_title: String = "scene1_monolog"
@export var next_scene_path: String = "res://cutscene/scene2/scene_2.tscn" # Add this export for next scene
@onready var intro_player: VideoStreamPlayer = $AspectRatioContainer/intro_video
@onready var loop_player: VideoStreamPlayer = $AspectRatioContainer/loop_video
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var fade_rect: ColorRect = $FadeRect

var has_played_loop = false
var dialogue_finished = false

func _ready():
	# Setup for 1280x720 resolution
	_setup_video_players()
	
	# Connect signals
	intro_player.finished.connect(_on_intro_finished)
	loop_player.finished.connect(_on_loop_finished)
	
	# Start with intro
	loop_player.hide()
	intro_player.play()
	
	if fade_rect:
		fade_rect.color = Color.TRANSPARENT
		fade_rect.visible = false
		# Make it cover entire screen
		fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

func _setup_video_players():
	# Simple approach that should work
	for player in [intro_player, loop_player]:
		# Set to full screen
		player.set_anchors_preset(Control.PRESET_FULL_RECT)
		player.expand = true
		player.set("stretch_mode", 4)  # Numeric value for centered aspect
	
	# Mute loop
	loop_player.audio_track = -1

func _on_intro_finished():
	# Intro finished, switch to loop
	intro_player.hide()
	loop_player.show()
	loop_player.play()
	
	# Play sound effect
	if sound_effect and audio_player:
		audio_player.stream = sound_effect
		audio_player.play()
	
	# Start dialogue
	if not has_played_loop:
		has_played_loop = true
		_run_dialogue()

func _on_loop_finished():
	# Loop video finished - replay it
	# Only keep looping if dialogue hasn't finished yet
	if not dialogue_finished:
		loop_player.play()
	else:
		# Dialogue finished, don't loop anymore
		loop_player.stop()

func _run_dialogue():
	var my_dialogue = load("res://dialogues/game_dialogue.dialogue")
	if my_dialogue:
		GameManager.is_dialog_active = true
		
		var balloon
		if dialogue_title != "":
			balloon = DialogueManager.show_dialogue_balloon(my_dialogue, dialogue_title)
		else:
			balloon = DialogueManager.show_dialogue_balloon(my_dialogue)
		
		if balloon:
			await balloon.tree_exited 
		
		GameManager.is_dialog_active = false
		dialogue_finished = true
		
		# Stop the loop and fade out
		_fade_out_and_exit()
	else:
		print("Dialogue file not found!")
		end_cutscene()

func _fade_out_and_exit():
	print("_fade_out_and_exit called")
	print("Is inside tree: ", is_inside_tree())
	print("Has tween: ", get_tree() != null)
	
	if not is_inside_tree():
		print("ERROR: Node is not in scene tree!")
		# Try to change scene anyway
		if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
			get_tree().change_scene_to_file(next_scene_path)
		return
	
	set_process_input(false)
	await get_tree().create_timer(0.5).timeout
	
	# Try multiple ways to create tween
	var tween = null
	if get_tree() != null:
		tween = get_tree().create_tween()
	
	if tween == null:
		print("WARNING: Could not create tween, using direct scene change")
		modulate = Color.BLACK
		await get_tree().create_timer(2.0).timeout
	else:
		print("Tween created successfully")
		tween.tween_property(self, "modulate", Color.BLACK, 1.5)
		await tween.finished
	
	print("Changing scene...")
	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)

func end_cutscene():
	# Legacy function for error handling
	dialogue_finished = true
	loop_player.stop()
	_fade_out_and_exit()
