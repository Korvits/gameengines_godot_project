extends Panel

@export var contents_label: Label

@export var total_label: Label

func _ready() -> void:
	MainUi.backpack_panel = self
	self.hide()
	refresh_inventory()
	
	Backpack.inventory_changed.connect(refresh_inventory)

# Called everytime discs are added or removed
func refresh_inventory() -> void:
	var total= Backpack.get_total_value()

	if Backpack.items.is_empty():
		contents_label.text = "Your backpack is empty."
	else:
		var lines := []

		for item in Backpack.items:
			lines.append("%s | %s | Sale: %d" % [
					item.disc_name,
					item.get_rarity_name(),
					Progression.get_sale_value(item.value)
				])

		contents_label.text = "\n".join(lines)

	total_label.text = "Total value: %d" % total
