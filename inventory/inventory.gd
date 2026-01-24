extends Node
class_name InventorySystem

# =========
# Konfigurasi slot
# =========

# Slot utama ada 3
const MAIN_SLOT_COUNT := 3
# Slot permanen ada di index 0 
const PERMANENT_SLOT_INDEX := 0

# =========
# Data Inventory
# =========
var main_slots: Array = []

func _ready() -> void:
	_initialize_inventory()

# =========
# Inisialisasi 
# =========
func _initialize_inventory() -> void:
	main_slots.resize(MAIN_SLOT_COUNT)
	
	# Slot 1 atau index 0 akan diisikan item permanen (Take $ Give)
	main_slots[PERMANENT_SLOT_INDEX] = {
			"id": "TnG",
			"name": "Take and Give",
			"permanent": true
	}
	
	# Slot kosong lainnya
	for i in range(1, MAIN_SLOT_COUNT):
		main_slots[i] = null
	
	# ========= TESTING BACK END =========
	print("[Inventory] Initialized")
	print_inventory()
	
# =========================
# DEBUG / CLI DISPLAY
# =========================
func print_inventory() -> void:
	print("")
	print("=== MAIN INVENTORY ===")
	for i in range(MAIN_SLOT_COUNT):
		if main_slots[i] == null:
			print("Slot", i + 1, ": (kosong)")
		else:
			print("Slot", i + 1, ": ", main_slots[i]["name"])

# =========================
# OPERASI DASAR
# =========================
func remove_item(slot_index: int) -> Variant:
	if slot_index < 0 or slot_index >= MAIN_SLOT_COUNT:
		print("[Error] Slot tidak valid")
		return false

	var item = main_slots[slot_index] # ← PENTING

	if item == null:
		print("[Inventory] Slot sudah kosong")
		return null

	if item.get("permanent", false):
		print("[Inventory] Item permanen tidak bisa dihapus")
		return false

	var removed_item: Dictionary = item
	main_slots[slot_index] = null

	print("[Inventory] Item dihapus dari slot", slot_index + 1)
	print_inventory()

	return removed_item


func add_item(item: Dictionary) -> bool:
	# Validasi item
	if not item.has("id") or not item.has("name"):
		print("[Inventory] Item tidak valid")
		return false

	# Cari slot kosong (lewati slot permanen)
	for i in range(1, MAIN_SLOT_COUNT):
		if main_slots[i] == null:
			main_slots[i] = item
			print("[Inventory] Item ditambahkan ke slot ", i + 1, ": ", item["name"])
			print_inventory()
			return true

	# Jika tidak ada slot kosong
	print("[Inventory] Inventory penuh")
	return false
