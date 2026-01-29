extends Control

@onready var settings_menu = $SettingsMenu
@onready var volume_slider = $SettingsMenu/MasterVolume/VolumeSlider
	
func _ready():
	# Pastikan menu tertutup saat start
	settings_menu.visible = false
	# Set nilai slider awal sesuai volume Master saat ini
	volume_slider.value = GameManager.settings.master

	
func _on_start_button_pressed():
	# 1. Nonaktifkan input agar pemain tidak menekan tombol berkali-kali saat fade
	set_process_input(false)
	
	# 2. Buat Tween untuk efek Fade Out (mengubah transparansi ke hitam/nol)
	var tween = create_tween()
	
	# Mengubah modulate (transparansi) seluruh MainMenu menjadi transparan dalam 1.5 detik
	tween.tween_property(self, "modulate", Color(0, 0, 0, 1), 1.5) 
	
	# 3. Tunggu sampai tween selesai
	await tween.finished
	
	# 4. Baru pindah ke scene cutscene
	get_tree().change_scene_to_file("res://cutscene/scene1/scene_1_cutscene.tscn")

func _on_settings_button_pressed() -> void:
	settings_menu.visible = true

# Fungsi saat tombol Back di dalam menu settings diklik
func _on_close_settings_pressed():
	settings_menu.visible = false

func _on_master_slider_value_changed(value: float) -> void:
	print("SLIDER VALUE:", value)
	AudioManager.set_master(value)
	GameManager.settings.master = value
	GameManager.save_settings()
