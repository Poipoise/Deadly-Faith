extends CanvasLayer

signal start_game


func _on_start_button_pressed():
	$Boom.play()
	$TitleScreenMusic.stop()
	$Label.hide()
	$StartButton.hide()
	$AnimationPlayer.play("Fade")
	await get_tree().create_timer(2).timeout
	start_game.emit()
	await $AnimationPlayer.animation_finished
	$Sprite2D.hide()
