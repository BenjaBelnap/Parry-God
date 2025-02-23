extends Control

var time: float = 0.0
var total_time: int = 10
var mseconds: int = 0
var seconds: int = 0
var minutes: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("start")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (total_time - time) < 0:
		stop()
		return
	time += delta
	mseconds = fmod(total_time - time, 1) * 100
	seconds = fmod(total_time - time, 60)
	minutes = fmod(total_time - time, 3600) / 60
	$Control/Minutes.text = "%02d:" % minutes
	$Control/Seconds.text = "%02d:" % seconds
	$Control/Mseconds.text = "%02d" % mseconds

func stop() -> void:
	set_process(false)
