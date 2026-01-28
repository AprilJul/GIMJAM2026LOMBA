extends Area2D

var triggered := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if triggered:
		return
	if body.is_in_group("Player") and GameManager.has_interact_teddy == false:
		var cutscene = get_tree().current_scene.find_child("CutsceneController", true, false)
		if cutscene:
			triggered = true
			cutscene.play_cutscene("interaction_teddy")
