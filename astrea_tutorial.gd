extends CharacterBody2D

func _physics_process(delta):
	$AnimationPlayer.play("Idle")
