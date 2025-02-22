extends CharacterBody2D  # Godot 4
@export var max_speed = 600	# Top speed
@export var acceleration = 2000 # How fast we speed up
@export var friction =3000  # How fast we slow down

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_in_group("player"):
		print("Player is in the group!")



func _physics_process(delta):
	var input_dir = Vector2.ZERO

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
