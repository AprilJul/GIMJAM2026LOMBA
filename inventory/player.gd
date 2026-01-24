extends Node2D

@onready var inventory := InventorySystem.new()

func _ready() -> void:
	add_child(inventory)

	# Test manual
	inventory.remove_item(0) # ❌ harus gagal (permanen)
	inventory.add_item({
		"id": "2" ,
		"name": "Test Object",
		"permanent": false
	})
	inventory.add_item({
		"id": "3" ,
		"name": "Test Object (2)",
		"permanent": false
	})
	inventory.remove_item(1)

# Nanti fungsi remove sama add bakal disesuaikan dengan kondisi realtime dalam game (interact event)
