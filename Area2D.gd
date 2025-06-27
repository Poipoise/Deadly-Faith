extends Area2D

signal player_entered



func _on_body_entered(_body):
	player_entered.emit()
