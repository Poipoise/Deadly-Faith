extends CanvasLayer
signal respawn
var game_over = false


func _on_player_game_over():
	$AnimationPlayer.play("Fade in")
	$DeathMusic.play()
	game_over = true
	await $DeathMusic.finished
	if game_over:
		$DeathMusicloop.play()

func _input(event):
	if event.is_action_pressed("UI_Interaction") and game_over:
		$Respawn.play()
		respawn.emit()
		$AnimationPlayer.play("fade out")
		$DeathMusic.stop()
		$DeathMusicloop.stop()
		game_over = false
