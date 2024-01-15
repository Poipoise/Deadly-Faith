extends CanvasLayer
signal respawn
var game_over = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _on_player_game_over():
	$AnimationPlayer.play("Fade in")
	$DeathMusic.play()
	game_over = true

func _input(event):
	if event.is_action_pressed("UI_Interaction") and game_over:
		$Respawn.play()
		respawn.emit()
		$AnimationPlayer.play("fade out")
		$DeathMusic.stop()
		game_over = false
