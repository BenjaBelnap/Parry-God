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
@export var parry_speed = .3
@export var max_hp = 100
@export var current_state = State.IDLE
@onready var hp = max_hp
@export var parry_cooldown = 1.0	# Seconds between parries
var parry_timer = ParryTiming.new()
var input_lockout = false
var parry_lockout = false

@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var hurt_audio:AudioStreamPlayer2D = $Audio/HurtAudio
@onready var perfect_audio = $Audio/PerfectParry
@onready var parry_audio = $Audio/NormalParry
@onready var camera:Camera2D = $Camera2D
@onready var hp_bar:ProgressBar = $Camera2D/Control/HpBar
@onready var attack_hitbox: Area2D = $AttackHitbox

signal dead
signal attack_hit(damage)


func _on_hit(attack_damage: int):
	var timing = $Timer.wait_time - $Timer.time_left
	print("Did I take damge at ", timing, " ms?")
	if current_state == State.PARRY:
		if parry_timer.is_perfect_parry(timing):
			end_parry()
			anim_player.play("parry_success", 0)
			$Energy.add_energy(attack_damage * 1.5)
			perfect_audio.play()
			print("Perfect parry!")
			print("max Speed:", max_speed)
		elif parry_timer.is_normal_parry(timing):
			end_parry()
			anim_player.play("parry_success", 0)
			$Energy.add_energy(attack_damage)
			parry_audio.play()

		take_damage(attack_damage)
		

func take_damage(attack_damage: int):
	anim_player.play("hurt")
	hp -= attack_damage
	hp_bar.value = hp
	hurt_audio.play()
	if hp <= 0:
		emit_signal("dead")
		anim_player.play("die")
		input_lockout = true
		await get_tree().create_timer(1.8).timeout
		queue_free()


func attack():
		print("Player attacks!")
		anim_player.play("attack")
		$Energy.clear_energy()
		attack_hitbox.monitering = true


func _on_attack_hit():
	return


func change_state(new_state):
	current_state = new_state

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = parry_cooldown
	
	anim_player.update_parry_timing(parry_timer.perfect_window,parry_timer.normal_window,parry_cooldown)
	attack_hit.connect(_on_attack_hit)
	attack_hitbox.monitoring = false


func _physics_process(delta):
	var input_dir = Vector2.ZERO
	
	if input_lockout:
		return
	
	if !(current_state == State.PARRY):
		if Input.is_action_pressed("parry"):
			start_parry()
			Input.action_release("parry")
		elif Input.is_action_just_pressed("attack"):
			if $Energy.is_full():
				change_state(State.ATTACK)
				attack()
			else:
				print("Not enough energy.")
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	Input.action_release("parry")
	input_dir = input_dir.normalized()	# Prevent diagonal speed boost

	if input_dir != Vector2.ZERO:
		# Apply acceleration
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()


func start_parry():
	change_state(State.PARRY)
	max_speed = max_speed*parry_speed
	parry_lockout = true
	$Timer.start()
	print("Start parry.")
	anim_player.play("parry")
	
func end_parry():
	if current_state == State.PARRY:
		print("End parry.")
		change_state(State.IDLE)
		max_speed = max_speed /parry_speed

	elif current_state == State.ATTACK:
		print("End attack.")
	$Timer.stop()

func _on_timer_timeout():
	end_parry()
