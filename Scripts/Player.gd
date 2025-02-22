extends CharacterBody2D  # Godot 4

enum State { IDLE, ATTACK, PARRY }	# Define states

class ParryTiming:
	var perfect_window = 0.133333  # 133ms parry window
	var normal_window = 0.4  # 400ms for normal parry
	func is_perfect_parry(timing):
			return timing <= perfect_window

	func is_normal_parry(timing):
		return timing <= normal_window

@export var max_speed = 600	# Top speed
@export var acceleration = 2000 # How fast we speed up
@export var friction = 3000  # How fast we slow down
@export var current_state = State.IDLE

@export var parry_cooldown = 1.0	# Seconds between parries
var parry_timer = ParryTiming.new()
var input_lockout = false

@onready var anim_player = $AnimationPlayer

func take_damage(attack_damage: int):
	var timing = $Timer.wait_time - $Timer.time_left
	print("Did I take damge at ", timing, " ms?")
	if current_state == State.PARRY:
		if parry_timer.is_perfect_parry(timing):
			$Energy.add_energy(attack_damage * 1.5)
			print("Perfect parry!")
		elif parry_timer.is_normal_parry(timing):
			$Energy.add_energy(attack_damage)
			print("Normal parry.")
		else:
			print("Failed parry. Took ", attack_damage, " damage.")
	else:
		print("Took ", attack_damage, " damage.")


func change_state(new_state):
	current_state = new_state

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = parry_cooldown
	
	if is_in_group("player"):
		print("Player is in the group!")
	var parry:Animation = anim_player.get_animation("parry")
	parry.track_set_key_value(1,0,parry_timer.perfect_window)
	parry.track_set_key_value(1,1,parry_timer.normal_window)
	parry.track_set_key_value(1,2,parry_cooldown)


func _physics_process(delta):
	var input_dir = Vector2.ZERO
	
	if not input_lockout:
		if Input.is_action_pressed("parry"):
			change_state(State.PARRY)
			input_lockout = true
			$Timer.start()
			print("Start parry.")
			anim_player.play("parry")
		if Input.is_action_pressed("move_up"):
			input_dir.y -= 1
		if Input.is_action_pressed("move_down"):
			input_dir.y += 1
		if Input.is_action_pressed("move_left"):
			input_dir.x -= 1
		if Input.is_action_pressed("move_right"):
			input_dir.x += 1

	input_dir = input_dir.normalized()	# Prevent diagonal speed boost

	if input_dir != Vector2.ZERO:
		# Apply acceleration
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()


func _on_timer_timeout():
	change_state(State.IDLE)
	input_lockout = false
	print("End parry.")
	$Timer.stop()
