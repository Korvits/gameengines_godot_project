extends Node

signal inventory_changed
signal pickup_failed(message)
signal item_added(disc_data: DiscData)

var capacity: int:
	get:
		return Progression.get_backpack_capacity()

var items: Array[DiscData] = []


func _ready() -> void:
	Progression.upgrade_purchased.connect(_on_upgrade_purchased)
	

func is_full() -> bool:
	return items.size() >= capacity


func try_add(disc_data: DiscData) -> bool:
	if disc_data == null:
		return false

	if is_full():
		# MainUI listens to this
		pickup_failed.emit("Backpack full! This disc stays here.")
		return false

	items.append(disc_data)
	Progression.discs_collected += 1
	
	inventory_changed.emit()
	item_added.emit(disc_data)
	
	return true


func get_total_value() -> int:
	var total = 0

	for item in items:
		total += Progression.get_sale_value(item.value)

	return total


func _on_upgrade_purchased(upgrade_id: String) -> void:
	if upgrade_id == "capacity" or upgrade_id == "value":
		inventory_changed.emit()
