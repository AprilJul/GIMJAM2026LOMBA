
extends Node

var has_opened_map: bool = false
var is_dialog_active := false
var sanity = 100
var memory_shards = 0

signal sanity_changed(value)
@onready var sanity_timer := Timer.new()
var chatbox = null

# GameManager.gd
func start_intro_dialogue():
# Mencari chatbox secara dinamis jika belum ada
	_find_chatbox()
	if chatbox:
		chatbox.start_dialogue([
			"Tempat ini terasa tidak aman...",
			"Ada sesuatu yang mengawasiku.",
			"Aku harus segera pergi."
		])

func _find_chatbox():
	# Mencari node ChatBox di dalam scene tree yang sedang aktif
	if chatbox == null:
		chatbox = get_tree().current_scene.find_child("ChatBox", true, false)
		# Jika masih tidak ketemu, coba cari di root (tergantung struktur scene Anda)
		if chatbox == null:
			chatbox = get_tree().root.find_child("ChatBox", true, false)

func _ready():
	# Menambahkan timer 60 detik
	sanity_timer.wait_time = 60.0
	sanity_timer.autostart = true
	sanity_timer.timeout.connect(_on_sanity_timer_timeout)
	add_child(sanity_timer)

func _on_sanity_timer_timeout():
	sanity = max(sanity - 3, 0)
	emit_signal("sanity_changed", sanity)

# Kurangi sanity tiap timeout
func spend_sanity(amount: int) -> bool:
	if sanity >= amount:
		sanity -= amount
		# setiap sanity berubah -> kirim sinyal
		emit_signal("sanity_changed", sanity)
		return true
	return false

# Pause timer pada kondisi non-gameplay
func pause_sanity_timer():
	if sanity_timer:
		sanity_timer.paused = true

func resume_sanity_timer():
	if sanity_timer:
		sanity_timer.paused = false

# Function pause & resume timer untuk sanity
func pause_game():
	get_tree().paused = true
	GameManager.pause_sanity_timer()

func resume_game():
	get_tree().paused = false
	GameManager.resume_sanity_timer()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_find_chatbox()
		if chatbox:
			# Mendefinisikan typed array dengan benar
			var daftar_kalimat: Array[String] = [
				"Kalimat pertama: Tempat ini gelap.",
				"Kalimat kedua: Aku mendengar suara langkah kaki.",
				"Kalimat ketiga: Aku harus segera lari!"
			]
			chatbox.start_dialogue(daftar_kalimat)
