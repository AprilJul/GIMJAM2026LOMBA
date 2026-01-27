# GameUI.gd
extends CanvasLayer

@onready var panel = $Panel
@onready var label = $Panel/StoryText

func _ready():
	panel.hide() # Hide at start

func show_message(text: String):
	label.text = text
	panel.show()

func hide_message():
	panel.hide()
