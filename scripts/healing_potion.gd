class_name HealingPotion
extends StaticBody2D

const HEAL_PERCENT := 0.245

func heal_player(player: Player) -> void:
	player.heal_percent(HEAL_PERCENT)
