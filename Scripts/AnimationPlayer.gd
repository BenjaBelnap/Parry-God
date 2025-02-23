extends AnimationPlayer

var parry_list
# Called when the node enters the scene tree for the first time.
func _ready():
	parry_list = [get_animation("parry"), get_animation("parry_success")]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
