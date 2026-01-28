extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# If they haven't opened the map, keep triggering the hint
		if GameManager.has_opened_map == false:
			var cutscene = get_tree().current_scene.find_child("CutsceneController", true, false)
			if cutscene:
				cutscene.play_cutscene("tutorial_glitch")
