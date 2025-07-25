extends Area2D
var player
var lock_on = true

func _ready():
	player = $"../Player"
	
func _physics_process(delta):
	if lock_on:
		$AnimationPlayer.play("target_circle")
		global_position = player.global_position


func _on_lock_on_timer_timeout():
	lock_on = false
	$lightning_hit.play()
	await get_tree().create_timer(0.3).timeout
	$AnimationPlayer.play("lightning")
	await $AnimationPlayer.animation_finished
	$Sprite2D.visible = false
	await get_tree().create_timer(3.1).timeout
	queue_free()


func _on_body_entered(body):
	body.hurt(2, position.direction_to(body.position))
