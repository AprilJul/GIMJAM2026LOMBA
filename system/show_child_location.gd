extends Area2D

var triggered := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Body entered")
	if triggered:
		return
	if body.is_in_group("Player") and GameManager.has_reclaim_hallway == false:
		print("Triggered Cutscene: Tutorial")
		var cutscene = get_tree().current_scene.find_child("CutsceneController", true, false)
		if cutscene:
			triggered = true
			cutscene.play_cutscene("show_child_location")
