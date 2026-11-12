class_name CampStation
extends Area2D

var player_inside = false

@onready var spawner = $"../DiscSpawner"


func _ready() -> void:
	MainUi.camp = self
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = true
	MainUi.camp_availability_changed.emit()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = false
	MainUi.camp_availability_changed.emit()

func sell_all() -> int:
	if not player_inside:
		return 0

	if Backpack.items.is_empty():
		return 0

	var payout = Backpack.get_total_value()

	Backpack.items.clear()
	Progression.money += payout

	Backpack.inventory_changed.emit()
	Progression.money_changed.emit()

	return payout


func replenish_field() -> int:
	if not player_inside:
		return 0

	return spawner.replenish_discs()
	
func buy_upgrade(upgrade_id) -> bool:
	if not player_inside:
		return false

	return Progression.buy_upgrade(upgrade_id)
