extends Node

#preload obstacles
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var bird_heights := [200, 390]

#game variables
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000 / 2
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs
var firstTimeHit :bool = false 
var isFlying : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$PreStartTheme.play()
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	$GameOver.hide()
	new_game()

func new_game():
	#reset variables
	score = 0
	show_score()
	game_running = false
	firstTimeHit = false
	get_tree().paused = false
	
	$MainTheme.play()
	difficulty = 0
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#reset the nodes
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#reset hud and game over screen
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		#speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#generate obstacles
		generate_obs()
		
		#move dino and camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		#update score
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 600):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + randi_range(score, score + 100) + 200 + (i * 100)
			var obs_y : int
			if obs_type == barrel_scene :
				obs_y = DINO_START_POS.y + 52
			else:
				obs_y = DINO_START_POS.y + 41
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		#additionally random chance to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 125
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	
	if body.name == "Dino":
		if !firstTimeHit:
			firstTimeHit=true
			$DeathSound.play()
			game_over()
		
func _input(event):
	if isFlying:
		if Input.is_action_pressed("ui_accept"):
			if $Dino.flying:
				$Dino.flap()
func start_FlyingMode():
	isFlying = true
	$Dino.flying = true
	$Dino.flap()

func show_score():
	$HUD.get_node("Scores").get_node("ScoreLabel").text = "SCORE " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("Scores").get_node("HighScoreLabel").text = "BEST " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	# Reproduce el sonido de muerte
	



	# Verificar y actualizar la puntuación más alta
	check_high_score()

	# Mostrar pantalla de Game Over
	$GameOver.get_node("Highscore").text = "BEST " + str(high_score / SCORE_MODIFIER)
	$GameOver.get_node("Score").text = "SCORE " + str(score / SCORE_MODIFIER)
	
	if score >= high_score:
		$GameOver.get_node("GameOverScreen").hide()
		$GameOver.get_node("NewHighScore").show()
		
	else:
		$GameOver.get_node("GameOverScreen").show()
		$GameOver.get_node("NewHighScore").hide()
		
	$GameOver.show()
	
	await $DeathSound.finished
	# Pausar el juego
	get_tree().paused = true
