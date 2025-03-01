extends CanvasLayer
signal finished
@export var cutscene = true
@export var cutscene_next = false
func _on_color_rect_cutscene_finished():
	finished.emit()
	queue_free()




func _on_cutscene_finished():
	if cutscene:
		await get_tree().create_timer(1).timeout
		print("Its time")
		$AnimationPlayer.play("Fade in")
		cutscene_next = true
	if not cutscene:
		finished.emit()
		
func next_chat():
	cutscene_next = true
