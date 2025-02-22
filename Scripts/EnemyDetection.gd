extends Area2D

signal player_detected(player)
signal player_lost

func _on_body_entered(body):
	if body.is_in_group("player"):  # Ensure the player is in the "player" group
		emit_signal("player_detected", body)

func _on_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("player_lost")
