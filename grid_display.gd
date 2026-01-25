extends Node2D

@export var grid_size: int = 50
@export var grid_color: Color = Color(1, 1, 1, 0.2)
@export var region_size: Vector2 = Vector2(3072, 1728)

func _draw():
	# Draw Vertical Lines
	for x in range(0, region_size.x + grid_size, grid_size):
		draw_line(Vector2(x, 0), Vector2(x, region_size.y), grid_color, 1.0)
	
	# Draw Horizontal Lines
	for y in range(0, region_size.y + grid_size, grid_size):
		draw_line(Vector2(0, y), Vector2(region_size.x, y), grid_color, 1.0)

func _process(_delta):
	# Forces the grid to update if you change colors or visibility
	queue_redraw()
