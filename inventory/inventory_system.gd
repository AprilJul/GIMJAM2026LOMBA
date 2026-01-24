extends Node
class_name InventorySystem


@export var max_slots: int = 10

var items: Array[String] = []

func add_item(item_id: String) -> bool:
	if items.size() >= max_slots:
		print("Inventory penuh")
		return false
	
	items.append(item_id)
	print("Item ditambahkan:", item_id)
	return true


func remove_item(item_id: String) -> bool:
	if not items.has(item_id):
		print("Item tidak ditemukan:", item_id)
		return false
	
	items.erase(item_id)
	print("Item dihapus:", item_id)
	return true


func has_item(item_id: String) -> bool:
	return items.has(item_id)


func print_inventory() -> void:
	print("=== INVENTORY ===")
	
	if items.is_empty():
		print("Inventory kosong")
		return
	
	for i in items.size():
		print(str(i + 1) + ".", items[i])


# Setting interaksi dengan level sanity
func set_max_slots(new_max: int) -> void:
	max_slots = max(new_max, 0)
	print("Max slot inventory diubah menjadi:", max_slots)
	_handle_overflow()

func _handle_overflow() -> void:
	while items.size() > max_slots:
		var removed_item = items.pop_back()
		print("Item terbuang karena sanity rendah:", removed_item)
