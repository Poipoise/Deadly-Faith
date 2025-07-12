extends CanvasLayer
signal Done


func _on_final_cutscene_finished(_body):
	print("credits")
	$AnimationPlayer.play("Fade_in")
	await get_tree().create_timer(0.9).timeout
	$Boom.play()
	await get_tree().create_timer(2.6).timeout
	$Boom.play()
	await $AnimationPlayer.animation_finished
	Done.emit()
