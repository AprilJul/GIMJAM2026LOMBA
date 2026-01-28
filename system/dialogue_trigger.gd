extends Area2D

@export var dialogue_lines: Array[String] = []
var triggered := false

func _on_body_entered(body):
	if triggered:
		return

	if body.is_in_group("player"):
		triggered = true
		GameManager.chatbox.start_dialogue(dialogue_lines)
	
	print("Body:", body.name)
	print("Is Player:", body.is_in_group("player"))
	print("Dialogue count:", dialogue_lines.size())
