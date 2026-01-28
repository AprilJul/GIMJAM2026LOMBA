extends Marker2D

@onready var label = $VBoxContainer/Label
@onready var texture_rect = $VBoxContainer/TextureRect

# Daftar instruksi (Bisa diisi dari script lain)
var queue = [] 
var display_duration = 4.0 # Berapa lama instruksi muncul

func _ready():
	start_display()

func start_display():
	for item in queue:
		# 1. Update Konten
		label.text = item["text"]
		texture_rect.texture = item["image"]
		
		# 2. Fade In
		var tween_in = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_in.tween_property(self, "modulate:a", 1.0, 0.5) # Muncul dalam 0.5 detik
		await tween_in.finished
		
		# 3. Tunggu sebentar (Jeda baca)
		await get_tree().create_timer(display_duration).timeout
		
		# 4. Fade Out
		var tween_out = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_out.tween_property(self, "modulate:a", 0.0, 0.5) # Hilang dalam 0.5 detik
		await tween_out.finished
		
		# Jeda singkat sebelum teks berikutnya muncul
		await get_tree().create_timer(0.2).timeout
	
	# Hapus node setelah semua antrian selesai
	queue_free()
