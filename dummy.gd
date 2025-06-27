extends CharacterBody2D
var hit = 0
var done = false
signal dummy_hit
func _process(_delta):
	if hit >= 3 and not done:
		done = true
		dummy_hit.emit()

func hurt(_amount, dir):
		hit += 1
		$HitParticle.process_material.direction.x = sign (dir.x * 100)
		$HitParticle.process_material.direction.y = sign (dir.y * 100)
		$Sprite2D.material.set_shader_parameter("active", true)
		$AnimationPlayer.play("Hit")
		$HitParticle.emitting = true
		await get_tree().create_timer(0.1).timeout
		$HitParticle.emitting = false
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.material.set_shader_parameter("active", false)
