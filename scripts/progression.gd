extends Node

signal money_changed
signal upgrade_purchased(upgrade_id: String)
signal run_won

const MAX_UPGRADE_LEVEL = 3
var money = 3000
const TOURNAMENT_COST = 1000

var run_finished= false
var run_seconds = 0.0
var discs_collected = 0

const BASE_COSTS = {
	"walk": 40,
	"search": 40,
	"capacity": 50,
	"luck": 70,
	"value": 60,
	"scanner": 120
}

const UPGRADE_NAMES = {
	"walk": "Walking speed",
	"search": "Searching speed",
	"capacity": "Backpack capacity",
	"luck": "Luck",
	"value": "Sale value",
	"scanner": "Scanner"
}

var upgrade_levels = {
	"walk": 0,
	"search": 0,
	"capacity": 0,
	"luck": 0,
	"value": 0,
	"scanner": 0
}


func _process(delta: float) -> void:
	if not run_finished:
		run_seconds += delta

func get_upgrade_level(upgrade_id) -> int:
	return int(upgrade_levels.get(upgrade_id, 0))


func get_upgrade_name(upgrade_id) -> String:
	return str(UPGRADE_NAMES.get(upgrade_id, "Unknown upgrade"))


func is_maxed(upgrade_id) -> bool:
	return get_upgrade_level(upgrade_id) >= MAX_UPGRADE_LEVEL


func get_upgrade_cost(upgrade_id) -> int:
	if not BASE_COSTS.has(upgrade_id):
		return 0

	if is_maxed(upgrade_id):
		return 0

	var base_cost = int(BASE_COSTS[upgrade_id])
	var current_level = get_upgrade_level(upgrade_id)

	return base_cost * (current_level + 1)


func can_buy_upgrade(upgrade_id) -> bool:
	if run_finished:
		return false
	
	if is_maxed(upgrade_id):
		return false

	return money >= get_upgrade_cost(upgrade_id)


func buy_upgrade(upgrade_id) -> bool:
	if not can_buy_upgrade(upgrade_id):
		return false

	var cost = get_upgrade_cost(upgrade_id)

	money -= cost
	upgrade_levels[upgrade_id] = get_upgrade_level(upgrade_id) + 1

	money_changed.emit()
	upgrade_purchased.emit(upgrade_id)

	return true

# Calculations were made with AI so i could use multiplication instead of holding 
# static values for every level

func get_move_speed() -> float:
	return 180.0 + 30.0 * get_upgrade_level("walk")


func get_search_duration() -> float:
	return 1.0 - 0.15 * get_upgrade_level("search")


func get_backpack_capacity() -> int:
	return 5 + 2 * get_upgrade_level("capacity")


func get_sale_multiplier() -> float:
	return 1.0 + 0.2 * get_upgrade_level("value")


func get_sale_value(base_value) -> int:
	return roundi(base_value * get_sale_multiplier())


func get_rarity_weights() -> Array[int]:
	var luck_level = get_upgrade_level("luck")

	
	return Array([
		60 - 10 * luck_level,
		25 + 4 * luck_level,
		12 + 4 * luck_level,
		3 + 2 * luck_level
	])

func has_scanner() -> bool:
	return get_upgrade_level("scanner") > 0


func get_scanner_range() -> float:
	var level = get_upgrade_level("scanner")

	if level == 0:
		return 0.0

	return 140.0 + 50.0 * (level - 1)

func can_enter_tournament() -> bool:
	return not run_finished and money >= TOURNAMENT_COST
	
func enter_tournament() -> void:
	if not can_enter_tournament():
		return
	
	money -= TOURNAMENT_COST
	run_finished = true
	
	money_changed.emit()
	run_won.emit()

func reset_run() -> void:
	money = 0
	run_finished = false
	run_seconds = 0
	discs_collected = 0
	
	for upgrade_id in upgrade_levels:
		upgrade_levels[upgrade_id] = 0
