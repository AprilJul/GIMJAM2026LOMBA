extends Area2D

# How transparent should the player become? (0.0 to 1.0)
@export var ghost_alpha: float = 0.5

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# We use a Tween for a smooth professional "fade"
		var tween = create_tween()
		tween.tween_property(body, "modulate:a", ghost_alpha, 0.15)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		# Fade the player back to solid
		var tween = create_tween()
		tween.tween_property(body, "modulate:a", 1.0, 0.15)
