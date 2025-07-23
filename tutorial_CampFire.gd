extends StaticBody2D
signal set_spawn
var available = true
var in_area = false
var doing_tutorial = false
signal camp_fire_tutorial_done
func _ready():
	$CanvasLayer/Label.hide()

func _on_area_2d_body_entered(_body):
	in_area = true
	$CanvasLayer.show()
	$CanvasLayer/Label.show()
	
	


func _on_area_2d_body_exited(_body):
	in_area = false
	$CanvasLayer/Label.hide()


func _on_timer_timeout():
	available = true

func _input(event):
	if event.is_action_pressed("interact") and in_area and available:
		if doing_tutorial:
			camp_fire_tutorial_done.emit()
		$smoke.emitting = true
		$Set.play()
		set_spawn.emit()
		available = false
		$Timer.start()
		await get_tree().create_timer(3).timeout
		$smoke.emitting = false
