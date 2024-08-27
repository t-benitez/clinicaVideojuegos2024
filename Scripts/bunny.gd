extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -2200
var jumped = false
var ducked = false

#func _input(event: InputEvent) -> void:
	#if event is InputEventScreenDrag:
		#ducked = true
	#elif event is InputEventScreenTouch:
		#jumped = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("ui_accept") or jumped:
				velocity.y = JUMP_SPEED
				#$JumpSound.play()
			elif Input.is_action_pressed("ui_down") or ducked:
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled = true
				
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
		if Input.is_action_pressed("ui_down") or ducked:
			velocity.y += GRAVITY * delta * 3
		
	move_and_slide()
