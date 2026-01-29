extends Node2D

@export var background_image: Texture2D
@export var audio_loop: AudioStream
@export var next_scene_path: String = "res://cutscene/scene5f/scene_5f.tscn"
@export var loop_duration: float = 2.0  # How long to show the image before dialogue
@export var fade_in_duration: float = 1.5
@export var fade_out_duration: float = 1.5
@export var fade_delay: float = 0.5

@onready var background_sprite: VideoStreamPlayer = $VideoStreamPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer   # Changed to AudioStreamPlayer2D

var dialogue_finished = false
var loop_timer: Timer

func _ready():
	# Add AudioStreamPlayer2D if it doesn't exist
	if not has_node("AudioStreamPlayer"):
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "AudioStreamPlayer2D"
		add_child(audio_player)
		audio_player.owner = self if is_inside_tree() else null
	
	# Start with black screen
	modulate = Color.BLACK
	
	# Setup background image
	if background_image:
		background_sprite.texture = background_image
	
	# Setup audio
	if audio_loop:
		audio_player.stream = audio_loop
	
	# Start with fade in
	_fade_in()

func _fade_in():
	print("Scene 2: Fade in started")
	
	# Disable input during transition
	set_process_input(false)
	
	# Setup audio fade in
	if audio_player:
		audio_player.volume_db = -80.0
		if audio_loop:
			audio_player.play()
	
	# Create fade in tween
	var tween = get_tree().create_tween()
	if tween:
		# Fade visual from black to normal
		tween.tween_property(self, "modulate", Color.WHITE, fade_in_duration)
		
		# Fade audio in parallel
		if audio_player:
			tween.parallel().tween_property(audio_player, "volume_db", 0.0, fade_in_duration)
		
		await tween.finished
	else:
		# Fallback
		modulate = Color.WHITE
		if audio_player:
			audio_player.volume_db = 0.0
		await get_tree().create_timer(fade_in_duration).timeout
	
	# Re-enable input
	set_process_input(true)
	
	print("Scene 2: Fade in complete")
	
	# Start the scene sequence
	_start_scene_sequence()

func _start_scene_sequence():
	print("Scene 2: Starting scene sequence")


func _fade_out_and_exit():
	print("Scene 2: Starting fade out")
	
	set_process_input(false)
	
	# Optional delay before fade out
	if fade_delay > 0:
		await get_tree().create_timer(fade_delay).timeout
	
	# Create fade out tween
	var tween = get_tree().create_tween()
	if tween:
		# Fade visual to black
		tween.tween_property(self, "modulate", Color.BLACK, fade_out_duration)
		
		# Fade audio
		if audio_player and audio_player.playing:
			tween.parallel().tween_property(audio_player, "volume_db", -80.0, fade_out_duration)
		
		await tween.finished
	else:
		# Fallback
		modulate = Color.BLACK
		if audio_player and audio_player.playing:
			audio_player.volume_db = -80.0
		await get_tree().create_timer(fade_out_duration).timeout
	
	# Stop audio completely
	if audio_player:
		audio_player.stop()
	
	# Short pause on black screen
	await get_tree().create_timer(0.5).timeout
	
	print("Scene 2: Changing scene...")
	
	# Change scene
	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Scene 2: Next scene path not set or not found: ", next_scene_path)


func _on_video_stream_player_finished() -> void:
	_fade_out_and_exit()
