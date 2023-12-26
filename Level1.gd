extends TileMap
@export var enemy : PackedScene
@export var projectile : PackedScene
var summon_position
var summon_amount = 0
var summon_state = false
var counter = 0
var direction
var play = true
var start = false
var gameover = false

func _process(delta):
	if summon_state:
		summon_state = false
		summon_position.x -= 250
		while counter < summon_amount:
			var enemy_number = randi_range(-150, 150)
			summon_position.y += enemy_number
			var summons = enemy.instantiate()
			add_child(summons)
			summons.position = summon_position
			summons.summon()
			counter += 1
