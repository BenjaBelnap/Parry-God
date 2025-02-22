extends Control

var game_board:PackedScene = preload("res://Senes/game_board.tscn")
@onready var menu_one = $MenuOne
@onready var level_select = $LevelSelect

# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuOne/StartButton.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_game():
	get_tree().change_scene_to_packed(game_board)


func _on_start_button_pressed() -> void:
	menu_one.visible = false
	level_select.visible = true


func _on_option_button_pressed() -> void:
	print("Bring up options.")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_level_one_pressed():
	Global.level = 1
	start_game()
