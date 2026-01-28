extends Resource

class_name Inv

@export var items: Array[InvItem] = []

# Fungsi baru untuk menambah item
func insert(item: InvItem):
	# Mencari apakah ada slot yang kosong (nil/null)
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item
			return # Berhenti setelah menemukan satu slot kosong
	
	# Jika tidak ada slot kosong tapi array belum penuh (opsional, tergantung desain)
	# items.append(item)
