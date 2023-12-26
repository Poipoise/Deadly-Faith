extends CanvasLayer
signal finished
@export var cutscene = true

func _on_color_rect_cutscene_finished():
	finished.emit()
	queue_free()


func _on_start_screen_start_game():
	$AnimationPlayer.play("Fade in")
	if not cutscene:
		finished.emit()
