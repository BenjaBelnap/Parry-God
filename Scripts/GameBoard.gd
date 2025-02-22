extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_over_anim: AnimationPlayer = $"Game Over/AnimationPlayer"
@onready var game_over: Control = $"Game Over"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_player_death():
	print("player died")
	game_over.position = player.position
	
	game_over_anim.play("fade_in")
