extends CanvasLayer
signal finished
@export var cutscene = true
@export var cutscene_started = false
var tel_location

func _on_color_rect_cutscene_finished():
	cutscene_started = false
	$AnimationPlayer.play("Fade out")
	await get_tree().create_timer(0.8).timeout
	finished.emit(tel_location)



func _on_start_screen_start_game(file_path, location):
	tel_location = location
	$ColorRect.cutscene_setup(file_path)
	$AnimationPlayer.play("Fade in")
	cutscene_started = true
	if not cutscene:
		finished.emit()
