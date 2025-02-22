extends CharacterBody2D

enum State { IDLE, ATTACK }  # Define states

@export var attack_interval = 2.0  # Seconds between attacks
@export var attack_damage = 10  # Damage dealt
@export var attack_range = 100  # Distance to attack
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var max_speed = 300

@onready var detectionArea: Area2D = $DetectionArea
@onready var attackHitbox: Area2D = $AttackHitbox
@onready var attackTimer: Timer = $Timer
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@export var current_state = State.IDLE
var player = null
var on_cooldown = false

signal attack_hit(damage)  # Signal for when an attack hits the player

func _ready():
	set_physics_process(false)
	call_deferred("wait_for_physics")
	
	attackTimer.wait_time = attack_interval
	attackTimer.timeout.connect(_on_timer_timeout)
	attackTimer.start()
	
	# Connect signals
	detectionArea.connect("player_detected", _on_player_detected)
	detectionArea.connect("player_lost", _on_player_lost)
	attackHitbox.body_entered.connect(_on_attack_hit)


func wait_for_physics():
	await get_tree().physics_frame
	set_physics_process(true)

func _on_player_detected(new_player):
	player = new_player
	change_state(State.ATTACK)

func _on_player_lost():
	player = null
	change_state(State.IDLE)

func _process(delta):
	match current_state:
		State.IDLE:
			pass
		State.ATTACK:
			if !on_cooldown:
				attack()

func attack():
	print("Enemy attacks!")  
	on_cooldown = true
	animationPlayer.play("swipe")  # Play attack animation

	# Enable attack hitbox briefly
	await get_tree().create_timer(0.4).timeout
	attackHitbox.monitoring = true

	# Disable hitbox after short window
	await get_tree().create_timer(0.4).timeout
	attackHitbox.monitoring = false

	attackTimer.start()

func _on_attack_hit(body):
	if body.is_in_group("player"):
		print("Enemy hit the player!")
		emit_signal("attack_hit", attack_damage)  # Send damage to player

func change_state(new_state):
	current_state = new_state

func _physics_process(delta: float) -> void:
	if player:
		if navigation_agent.is_navigation_finished() and\
		player.global_position == navigation_agent.target_position:
			navigation_agent.target_position = player.global_position
			velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * max_speed
			move_and_slide()

func _on_timer_timeout():
	on_cooldown = false
