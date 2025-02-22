extends AnimationPlayer

var parry_list
# Called when the node enters the scene tree for the first time.
func _ready():
	parry_list = [get_animation("parry"), get_animation("parry_success")]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_parry_timing(perfect:int, normal:int,duration):
	for parry in parry_list:
		parry.track_set_key_time(0,0,perfect)
		parry.track_set_key_time(0,1,normal)
		parry.track_set_key_time(0,2,duration)
		parry.set_length(duration)
