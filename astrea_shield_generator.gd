extends StaticBody2D
var health = 4
signal crystal_destroyed

func _ready():
	$CollisionPolygon2D.disabled = true
	$Sprite2D.visible = false
	
func hurt(amount, dir):
	$Hit.play()
	health -= amount
	$Sprite2D.material.set_shader_parameter("active", true)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("active", false)
	if health <= 0:
		crystal_destroyed.emit()
		$AnimationPlayer.play("Destroyed")
		$CollisionPolygon2D.disabled = true

func activate_shield():
	health = 4
	$AnimationPlayer.play("appear")
	$Sprite2D.visible = true
	$CollisionPolygon2D.disabled = false
