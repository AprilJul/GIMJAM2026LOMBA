extends CharacterBody2D

@onready var inventory: InventorySystem = InventorySystem.new()

var sanity := 100
const MAX_SANITY := 100

func _ready() -> void:
	add_child(inventory)

	# TEST AWAL
	inventory.add_item("potion")
	inventory.add_item("key")
	inventory.add_item("map")
	inventory.add_item("knife")
	inventory.print_inventory()


func reduce_sanity(amount: int) -> void:
	sanity = max(sanity - amount, 0)
	print("Sanity turun:", sanity)

	_update_inventory_capacity()


func _update_inventory_capacity() -> void:
	# Contoh rule:
	# setiap 25 sanity hilang → -2 slot
	@warning_ignore("integer_division")
	var lost = (MAX_SANITY - sanity) / 25
	var new_max = 10 - (lost * 2)
	
	inventory.set_max_slots(new_max)


func _process(_delta):
	# TEST COMMAND
	if Input.is_action_just_pressed("ui_accept"):
		reduce_sanity(25)
		inventory.print_inventory()
