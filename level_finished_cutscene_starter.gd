extends Area2D
var active = false
signal start_cutscene

func _on_necromancer_died():
	active = true


func _on_body_entered(_body):
	if active:
		print("Activated")
		start_cutscene.emit("res://cutscenes/Final_cutscene.json", Vector2(4702, -604))
