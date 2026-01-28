extends Area2D

# Tarik file .tres yang Anda buat tadi ke slot ini di Inspector
@export var item: InvItem 

func _on_body_entered(body):
	# Kita asumsikan player memiliki variabel 'inventory'
	if body.has_method("collect"):
		body.collect(item)
		queue_free() # Hilangkan item dari dunia setelah diambil
