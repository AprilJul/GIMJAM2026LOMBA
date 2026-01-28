extends CanvasLayer

# This scene is used to make an item zoom animation when obtained
@onready var item_sprite = $ItemSprite

func _ready():
	# Menambahkan warna background sementara untuk melihat area TextureRect
	item_sprite.self_modulate = Color(1, 1, 1, 1) 
	print("ItemGetUI muncul di Scene Tree")
	
func play_get_animation(item_texture: Texture2D, target_position: Vector2):
	# 1. Pastikan TextureRect memiliki ukuran dasar 32x32
	item_sprite.custom_minimum_size = Vector2(32, 32)
	item_sprite.texture = item_texture
	
	# 2. Paksa Pivot ke Tengah (16,16) dan Anchor ke Tengah Layar
	item_sprite.pivot_offset = Vector2(16, 16)
	item_sprite.set_anchors_preset(Control.PRESET_CENTER) 
	
	# 3. Setup Awal
	item_sprite.scale = Vector2(0, 0)
	item_sprite.modulate.a = 0
	
	var tween = create_tween().set_parallel(false)
	
	# Animasi 1: Zoom In di Tengah Layar
	# Karena sudah di-anchor ke CENTER, kita cukup mainkan scale
	tween.tween_property(item_sprite, "scale", Vector2(6, 6), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(item_sprite, "modulate:a", 1.0, 0.2)
	
	tween.tween_interval(0.8)
	
	# Animasi 2: Terbang ke arah Player
	# Kita harus mematikan Anchor agar bisa menggunakan global_position dengan bebas
	var fly_tween = create_tween().set_parallel(true)
	fly_tween.tween_property(item_sprite, "global_position", target_position, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly_tween.tween_property(item_sprite, "scale", Vector2(0.3, 0.3), 0.6)
	fly_tween.tween_property(item_sprite, "modulate:a", 0.0, 0.6)
	
	await fly_tween.finished
	queue_free()
