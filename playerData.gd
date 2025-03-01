extends Resource
class_name PlayerData

@export var Savepos : Vector2
@export var health2 = 5
@export var attack_dmg = 1

func change_Savepos(value : Vector2):
	Savepos = value

func change_attack_dmg(damage : int):
	attack_dmg = damage

