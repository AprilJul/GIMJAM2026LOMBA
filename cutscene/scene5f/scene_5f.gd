extends Node2D
@export var fade_in_duration: float = 1.5
@export var fade_out_duration: float = 2
@export var fade_delay: float = 0.1
@export var next_scene_path: String = "res://cutscene/scene5f/scene_5f.tscn"

func _ready():
	_fade_in()
	
func _fade_in():
	print("Scene 5f: Fade in started")
	
	# Disable input during transition
	set_process_input(false)
	
	# Create fade in tween
	var tween = get_tree().create_tween()
	if tween:
		# Fade visual from black to normal
		tween.tween_property(self, "modulate", Color.WHITE, fade_in_duration)
	
	# Re-enable input
	set_process_input(true)
	
	print("Scene 5f: Fade in complete")
	
func _on_video_stream_player_finished() -> void:
	_fade_out_and_exit()

func _fade_out_and_exit():
	print("Scene 5f: Starting fade out")
	
	set_process_input(false)
	
	# Optional delay before fade out
	if fade_delay > 0:
		await get_tree().create_timer(fade_delay).timeout
	
	# Create fade out tween
	var tween = get_tree().create_tween()
	if tween:
		# Fade visual to black
		tween.tween_property(self, "modulate", Color.BLACK, fade_out_duration)
	# Short pause on black screen
	await get_tree().create_timer(0.5).timeout
	
	print("Scene 5f: Changing scene...")
	
	# Change scene
	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Scene 5f: Next scene path not set or not found: ", next_scene_path)
