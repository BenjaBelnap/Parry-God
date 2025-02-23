extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var game_over_anim: AnimationPlayer = $"Game Over/AnimationPlayer"
@onready var game_over: Control = $"Game Over"
@onready var background_music = $AudioStreamPlayer
var level:PackedScene
var level_instance:Node
var enemies: Node
var nuke_it = false
# Called when the node enters the scene tree for the first time.
func _ready():
	level = load("res://Senes/Levels/level" + str(Global.level) +".tscn")
	level_instance = level.instantiate()
	add_child(level_instance)
	enemies = level_instance.enemies
	for enemy in enemies.get_children():
		enemy.death.connect(_on_enemy_death)

func _on_enemy_death():
	print("AN enemy died.")
	await get_tree().create_timer(2.1).timeout
	if not enemies.get_children():
		print("You beat the level.")
		nuke_it = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if nuke_it == true:
		get_tree().change_scene_to_file("res://Senes/main.tscn")

func test():
	print("test")

func _on_player_death():
	print("player died")
	game_over.position = player.position
	
	game_over_anim.play("fade_in")
	await get_tree().create_timer(2).timeout
	nuke_it = true


func _on_audio_stream_player_finished():
	background_music.play()
