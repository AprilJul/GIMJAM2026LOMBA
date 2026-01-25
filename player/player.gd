extends CharacterBody2D

var speed = 100

var player_state

@export var inv: Inv

func _physics_process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction.x  ==  0 and direction.y == 0:
		player_state = "idle"
	elif direction.x != 0 or direction.y != 0:
		player_state = "walking"
	
	velocity = direction * speed
	move_and_slide()
	
	play_animation(direction)
	
func play_animation(dir):
	if player_state == "idle":
		$AnimatedSprite2D.play("idle")
	elif player_state == "walking":
		if dir.y == -1:
			$AnimatedSprite2D.play("walk_back")
		if dir.x == 1:
			$AnimatedSprite2D.play("walk_right")
		if dir.y == 1:
			$AnimatedSprite2D.play("walk_front")
		if dir.x == -1:
			$AnimatedSprite2D.play("walk_left")
func player():
	pass
