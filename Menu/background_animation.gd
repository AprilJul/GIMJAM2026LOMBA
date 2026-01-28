extends AnimatedSprite2D

func _ready():
	# Hubungkan sinyal jika ukuran layar berubah saat game jalan
	get_tree().root.size_changed.connect(_on_resize)
	_on_resize()

func _on_resize():
	var screen_size = get_viewport_rect().size
	var texture_size = sprite_frames.get_frame_texture("animation", 0).get_size()
	
	# Hitung skala agar menutupi seluruh layar (Cover Mode)
	var scale_factor = max(screen_size.x / texture_size.x, screen_size.y / texture_size.y)
	scale = Vector2(scale_factor, scale_factor)
	
	# Posisikan tepat di tengah layar secara otomatis
	position = screen_size / 2
