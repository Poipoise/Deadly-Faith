extends Area2D
signal start_cutscene

func _on_body_entered(body):
	start_cutscene.emit("res://cutscenes/Dialog.json", Vector2(3551, -3844))
