extends Area2D

signal player_entered



func _on_body_entered(body):
	player_entered.emit()
