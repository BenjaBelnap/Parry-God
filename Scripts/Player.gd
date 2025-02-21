extends CharacterBody2D  # Godot 4
@export var speed = 200  # Movement speed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var direction = Vector2.ZERO  # Default no movement

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	direction = direction.normalized()  # Normalize for consistent speed
	velocity = direction * speed
	move_and_slide()
