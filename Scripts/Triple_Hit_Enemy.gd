extends CharacterBody2D

enum State { IDLE, ATTACK , DYING}  # Define states

@export var attack_interval = 3.5  # Seconds between attacks
@export var attack_damage = 20  # Damage dealt
@export var attack_range = 100  # Distance to attack

@export var max_hp = 10
@export var curr_hp = max_hp

@export var max_speed = 300	# Top speed
@export var acceleration = 2000 # How fast we speed up
@export var friction = 3000  # How fast we slow down
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@onready var detectionArea: Area2D = $DetectionArea
@onready var attackHitbox: Area2D = $AttackHitbox
@onready var attackTimer: Timer = $Timer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var swing_audio:AudioStreamPlayer2D = $Audio/Swing
@onready var death_audio:AudioStreamPlayer2D = $Audio/Death

@export var current_state = State.IDLE
var player:CharacterBody2D = null
var on_cooldown = false
signal death

signal attack_hit(damage)  # Signal for when an attack hits the player

func _ready():
	attackTimer.wait_time = attack_interval
	attackTimer.timeout.connect(_on_timer_timeout)
	attackTimer.start()
	
	# Connect signals
	detectionArea.connect("player_detected", _on_player_detected)
	detectionArea.connect("player_lost", _on_player_lost)
	attackHitbox.body_entered.connect(_on_attack_hit)


func _on_hit(attack_damage: int):
	print("Enemy got hit.")
	curr_hp -= attack_damage
	if curr_hp < 0:
		print("Enemy died.")
		change_state(State.DYING)
		death_audio.play()
		animationPlayer.play("death")
		await get_tree().create_timer(2).timeout
		emit_signal("death")
		queue_free()


func _on_player_detected(new_player):
	if current_state == State.DYING:
		return
	player = new_player
	change_state(State.ATTACK)
	attack_hit.connect(player._on_hit)
	player.attack_hit.connect(_on_hit)

func _on_player_lost():
	player = null
	change_state(State.IDLE)

func _process(delta):
	match current_state:
		State.DYING:
			pass
		State.IDLE:
			pass
		State.ATTACK:
			var dir = global_position.direction_to(player.global_position)
			rotation =  dir.angle()
			if !on_cooldown:
				attack()

func attack():
	print("Enemy attacks!")  
	on_cooldown = true
	animationPlayer.play("swipe")  # Play attack animation
	
	# Enable attack hitbox briefly
	await get_tree().create_timer(0.55).timeout
	attackHitbox.monitoring = true
	await get_tree().create_timer(0.2).timeout
	swing_audio.play()
	await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(0.08).timeout
	swing_audio.play()
	await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(0.45).timeout
	swing_audio.play()
	await get_tree().create_timer(0.2).timeout
	attackHitbox.monitoring = false

	attackTimer.start()

func _on_attack_hit(body):
	if body.is_in_group("player"):
		print("Enemy hit the player!")
		emit_signal("attack_hit", attack_damage)  # Send damage to player

func change_state(new_state):
	current_state = new_state

func _on_timer_timeout():
	on_cooldown = false
	

func _physics_process(delta: float) -> void:
	if player:
		navigation_agent.target_position = player.global_position
		if position.distance_to(navigation_agent.target_position) > 200:
			velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * max_speed
#
			#if input_dir != Vector2.ZERO:
				## Apply acceleration
				#velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
			#else:
				## Apply friction when no input
				#velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			
			move_and_slide()
