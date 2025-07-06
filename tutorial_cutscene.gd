extends CanvasLayer
signal finished
@export var cutscene = true
@export var cutscene_next = false
@export var first_dialog_done = false
func _on_color_rect_cutscene_finished():
	print("WE DONE")
	$AnimationPlayer.play("black_out")
	await get_tree().create_timer(0.7).timeout
	finished.emit()
	await $AnimationPlayer.animation_finished
	queue_free()




func _on_cutscene_finished():
	if cutscene:
		await get_tree().create_timer(1).timeout
		print("Its time")
		$AnimationPlayer.play("Fade in")
		cutscene_next = true
	if not cutscene:
		queue_free()
		finished.emit()
		
func next_chat():
	cutscene_next = true
