extends Node2D
@export var enemy : PackedScene
var summon_position
var summon_amount = 0
var summon_state = false
var counter = 0
func _process(delta):
	$CanvasLayer/StaminaBar.value = $Player.stamina
	if summon_state:
		summon_state = false
		summon_position.x -= 100
		while counter < summon_amount:
			var enemy_number = randi_range(-150, 150)
			summon_position.y = enemy_number
			var summons = enemy.instantiate()
			add_child(summons)
			summons.position = summon_position
			summons.summon()
			counter += 1


func _on_death_screen_respawn():
	var enemy_nodes = get_tree().get_nodes_in_group("enemy")
	for enemy in enemy_nodes:
		enemy.respawn()
