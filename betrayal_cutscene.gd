extends CanvasLayer
signal finished
@export var cutscene = true
@export var cutscene_started = false
var done = false
func _on_color_rect_cutscene_finished():
	finished.emit()
	$AudioStreamPlayer.stop()
	$background_music.stop()
	queue_free()



func _Astrea_betrayal_start():
	$AnimationPlayer.play("Fade in")
	$AudioStreamPlayer.play()
	$Timer.start()
	cutscene_started = true
	if not cutscene:
		queue_free()
		finished.emit()

func _on_timer_timeout():
	if $ColorRect.phraseNum >= 4 and not done:
		done = true
		$AudioStreamPlayer.stop()
		$background_music.play()
