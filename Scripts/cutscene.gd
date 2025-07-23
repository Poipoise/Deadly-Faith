extends CanvasLayer
signal finished
@export var cutscene = true
@export var cutscene_started = false
func _on_color_rect_cutscene_finished():
	finished.emit()
	queue_free()



func _on_title_page_finished():
	$AnimationPlayer.play("Fade in")
	cutscene_started = true
	if not cutscene:
		queue_free()
		finished.emit()
