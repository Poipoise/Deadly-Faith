extends CanvasLayer
signal respawn

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.hide()
	$Button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _on_player_game_over():
	$Button.show()
	$AnimationPlayer.play("Fade in")
	$AnimatedSprite2D.show()
	$DeathMusic.play()


func _on_button_pressed():
	$AnimatedSprite2D.hide()
	$Respawn.play()
	respawn.emit()
	$AnimationPlayer.play("fade out")
	$Button.hide()
	$DeathMusic.stop()
	
