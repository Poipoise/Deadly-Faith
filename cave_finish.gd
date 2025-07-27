extends Area2D
signal start_cutscene

func _on_body_entered(_body):
	start_cutscene.emit("res://cutscenes/CaveSystemEnd.json", Vector2(4515, 3993))
