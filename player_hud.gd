extends CanvasLayer

# Pastikan di Editor sudah klik kanan -> Access as Unique Name
@onready var backpack_button = %BackpackButton
@onready var map_button = %MapButton
@onready var inventory_ui = %Inv_UI 

func _ready():
	# Cek satu per satu untuk memastikan tidak ada yang null
	if backpack_button:
		backpack_button.pressed.connect(_on_backpack_pressed)
	else:
		print("ERROR: BackpackButton tidak ditemukan!")

	if map_button:
		map_button.pressed.connect(_on_map_pressed)
	else:
		print("ERROR: MapButton tidak ditemukan!")

func _on_backpack_pressed():
	# Pastikan inventory_ui ada sebelum akses .is_open
	if inventory_ui:
		if inventory_ui.is_open:
			inventory_ui.close()
		else:
			inventory_ui.open()
	else:
		print("ERROR: Inv_UI tidak ditemukan di HUD!")

func _on_map_pressed():
	print("Membuka Map...")
