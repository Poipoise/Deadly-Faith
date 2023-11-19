extends CanvasLayer

signal start_game

func _on_start_button_pressed():
	$Boom.play()
	$TitleScreenMusic.stop()
	$Label.hide()
	$StartButton.hide()
	$AnimationPlayer.play("Fade")
	await $AnimationPlayer.animation_finished
	$Sprite2D.hide()
	start_game.emit()
