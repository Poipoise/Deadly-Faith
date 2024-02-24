extends Area2D
var active = false
signal start_cutscene

func _on_necromancer_died():
	active = true


func _on_body_entered(body):
	if active:
		start_cutscene.emit()
