extends CharacterBody2D

enum State { IDLE, ATTACK }	# Define states

@export var attack_interval = 2.0	# Seconds between attacks
@export var attack_range = 100	# Distance to attack
@export var attack_damage = 10	# Damage dealt

@export var current_state = State.IDLE
var player = null
var on_cooldown = false

func _ready():
	$Timer.wait_time = attack_interval
	$Timer.start()
	
	# Connect signals
	$Area2D.connect("player_detected", _on_player_detected)
	$Area2D.connect("player_lost", _on_player_lost)


func _on_player_detected(new_player):
	player = new_player
	change_state(State.ATTACK)


func _on_player_lost():
	player = null
	change_state(State.IDLE)



func _process(delta):
	match current_state:
		State.IDLE:
			#look_for_player()
			pass
		State.ATTACK:
			if !on_cooldown:
				attack()

#func look_for_player():
	#if player and global_position.distance_to(player.global_position) < attack_range:
		#change_state(State.ATTACK)

func attack():
	print("Enemy attacks!")  # Replace with actual attack logic
	# Emit signal here if needed, like EventBus.emit_signal("enemy_attack")

	$Timer.start()	# Restart attack timer
	on_cooldown = true

func change_state(new_state):
	current_state = new_state

# Called when timer times out (Repeat attacks)
func _on_timer_timeout():
	on_cooldown = false


