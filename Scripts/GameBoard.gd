extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_over_anim: AnimationPlayer = $"Game Over/AnimationPlayer"
@onready var game_over: Control = $"Game Over"
@onready var background_music = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_death():
	print("player died")
	game_over.position = player.position
	
	game_over_anim.play("fade_in")
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Senes/main.tscn")


func _on_audio_stream_player_finished():
	background_music.play()
