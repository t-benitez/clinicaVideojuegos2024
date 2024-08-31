extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800
var activeModeRunning : bool = true

const FlappyBirdGravity : int = 1000
const Max_Vel : int = 600
const flapSpeed : int = -500
var flying : bool = false
var falling : bool = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if activeModeRunning:
		velocity.y += GRAVITY * delta
		if is_on_floor():
			if not get_parent().game_running:
				$AnimatedSprite2D.play("idle")
			else:
				$RunCol.disabled = false
				if Input.is_action_pressed("ui_accept"):
					velocity.y = JUMP_SPEED
					$JumpSound.play()
				elif Input.is_action_pressed("ui_down"):
					$AnimatedSprite2D.play("duck")
					$RunCol.disabled = true
					
				else:
					$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("jump")
			if Input.is_action_pressed("ui_down"):
				velocity.y += GRAVITY * delta * 3
	else:
		if flying or falling:
			velocity.y += FlappyBirdGravity * delta
			if velocity.y > Max_Vel:
				velocity.y = Max_Vel
			if flying:
				set_rotation(deg_to_rad(velocity.y*0.05))
			elif falling:
				set_rotation(PI/2)
			move_and_collide(velocity * delta)
		
			
	move_and_slide()
	
func flap():
	velocity.y = flapSpeed
