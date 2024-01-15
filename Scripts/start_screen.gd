extends CanvasLayer

signal start_game
var game_start = true

func _input(event):
	if event.is_action_pressed("UI_Interaction") and game_start:
		game_start = false
		$Boom.play()
		$TitleScreenMusic.stop()
		$Label.hide()
		$RichTextLabel.hide()
		$AnimationPlayer.play("Fade")
		await get_tree().create_timer(2).timeout
		start_game.emit()
		await $AnimationPlayer.animation_finished
		$Sprite2D.hide()
