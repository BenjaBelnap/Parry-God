extends Camera2D


func screen_shake(intensity: float = 8, duration: float = 0.2):
	var tween = get_tree().create_tween()
	for i in range(4):  # Shake in 4 directions
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(self, "offset", offset, duration / 4)
	tween.tween_property(self, "offset", Vector2.ZERO, duration / 4)  # Reset

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
