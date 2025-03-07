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
@export var invincibility_on_hit = 1.5
@export var invincibility_on_parry = 1.0

var parry_timing = ParryTiming.new()

var input_lockout = false
var parry_lockout = false

var is_invincible = false

@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var hurt_audio:AudioStreamPlayer2D = $Audio/HurtAudio
@onready var perfect_audio = $Audio/PerfectParry
@onready var parry_audio = $Audio/NormalParry
@onready var camera:Camera2D = $Camera2D
@onready var hp_bar:ProgressBar = $Camera2D/Control/HpBar
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var parry_timer = $ParryTimer


signal dead
signal attack_hit(damage)

signal invincible(time)

func win():
	$Victory.win()

func _on_hit(attack_damage: int):
	var timing = parry_timer.wait_time - parry_timer.time_left
	print("Did I take damge at ", timing, " ms?")
	if current_state == State.PARRY:
		if parry_timing.is_perfect_parry(timing):
			end_parry()
			anim_player.play("parry_success", 0)
			$Energy.add_energy(attack_damage * 1.5)
			perfect_audio.play()
			become_invincible(invincibility_on_parry)
		elif parry_timing.is_normal_parry(timing):
			end_parry()
			anim_player.play("parry_success", 0)
			$Energy.add_energy(attack_damage)
			parry_audio.play()
			become_invincible(invincibility_on_parry)
		else:
			take_damage(attack_damage)
	else:
		take_damage(attack_damage)
		

func become_invincible(time:int):
	print("invincible!")
	is_invincible = true
	await get_tree().create_timer(time).timeout
	is_invincible = false
	print("not invincible")
	


func take_damage(attack_damage: int):
	if !is_invincible:
		emit_signal("invincible",invincibility_on_hit)
		anim_player.play("hurt")
		hp = hp - attack_damage
		hp_bar.value = hp
		hurt_audio.play()
		$Camera2D.screen_shake(5,.1)
		
	if hp <= 0:
		emit_signal("dead")
		anim_player.play("die")
		input_lockout = true
		await get_tree().create_timer(1.8).timeout


func flicker_particles():
	var colors = [Color.RED, Color.BLUE, Color.PURPLE, Color.CYAN]
	var tween = get_tree().create_tween()
	
	for i in range(10):  # Flicker 5 times
		tween.tween_property($AttackHitbox/CPUParticles2D, "modulate", colors[randi() % colors.size()], 0.09)
		tween.tween_property($AttackHitbox/CPUParticles2D, "modulate", Color.WHITE, 0.09)
	
	tween.tween_property($AttackHitbox/CPUParticles2D, "modulate", Color(1,1,1,0), 0.1)  # Fade out at the end




func attack():
		print("Player attacks!")
		#anim_player.play("attack")
		$Energy.clear_energy()
		attack_hitbox.monitoring = true
		$Camera2D.screen_shake(20, .1)
		$AttackHitbox/CPUParticles2D.emitting = true
		$Audio/Magic.play()
		flicker_particles()
		await get_tree().create_timer(0.2).timeout
		attack_hitbox.monitoring = false
		$AttackHitbox/CPUParticles2D.emitting = true


func _on_attack_hit(enemy):
	if !enemy.is_in_group("player"):
		print("Player attack hit.")
		attack_hitbox.set_deferred("monitoring", false)
		emit_signal("attack_hit",50)


func change_state(new_state):
	current_state = new_state

# Called when the node enters the scene tree for the first time.
func _ready():
	parry_timer.wait_time = parry_cooldown
	

	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_attack_hit)


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
	parry_timer.start()
	print("Start parry.")
	anim_player.play("parry")
	
func end_parry():
	if current_state == State.PARRY:
		print("End parry.")
		change_state(State.IDLE)
		max_speed = max_speed /parry_speed

	elif current_state == State.ATTACK:
		print("End attack.")
	parry_timer.stop()

func _on_timer_timeout():
	end_parry()


func _on_level_timer_time_up() -> void:
		emit_signal("dead")
		anim_player.play("die")
		input_lockout = true
		await get_tree().create_timer(1.8).timeout
