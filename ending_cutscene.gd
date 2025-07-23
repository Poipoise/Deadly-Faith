extends CanvasLayer
signal finished
@export var cutscene = true
@export var cutscene_started = false
func _on_color_rect_cutscene_finished():
	finished.emit()
	$background_music.stop()
	queue_free()



func _Astrea_ending_start():
	$AnimationPlayer.play("Fade in")
	$background_music.play()
	cutscene_started = true
	if not cutscene:
		queue_free()
		finished.emit()
