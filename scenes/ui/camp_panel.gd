extends Panel

@export var sale_label: Label
@export var sell_button: Button 
@export var refill_button: Button 
@export var close_button: Button 
@export var tournament_button: Button

@export var walk_button: Button
@export var search_button: Button
@export var capacity_button: Button
@export var luck_button: Button
@export var value_button: Button
@export var scanner_button: Button

var upgrade_buttons

func _ready() -> void:
	MainUi.camp_panel = self
	self.hide()
	
	upgrade_buttons = {
	"walk": walk_button,
	"search": search_button,
	"capacity": capacity_button,
	"luck": luck_button,
	"value": value_button,
	"scanner": scanner_button
	}
	
	sell_button.pressed.connect(_on_sell_pressed)
	refill_button.pressed.connect(_on_refill_pressed)
	close_button.pressed.connect(close_menu)
	Backpack.inventory_changed.connect(refresh_inventory)
	
	tournament_button.pressed.connect(_on_tournament_pressed)
	
	for upgrade_id in upgrade_buttons:
		var button: Button = upgrade_buttons[upgrade_id]
		button.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))

	Progression.upgrade_purchased.connect(_on_upgrade_purchased)
	
	refresh_tournament_ui()
	refresh_upgrade_buttons()
	refresh_inventory()
	


func refresh_inventory() -> void:
	var count = Backpack.items.size()
	var total = Backpack.get_total_value()

	sale_label.text = "Discs: %d\nSale value: %d" % [count,total]

	sell_button.text = "Sell all for %d" % total
	sell_button.disabled = Backpack.items.is_empty()

func _on_sell_pressed() -> void:

	var earned = MainUi.camp.sell_all()

	if earned > 0:
		MainUi.show_message("Sold your discs for %d!" % earned)
	else:
		MainUi.show_message("Nothing to sell.")
		
func _on_refill_pressed() -> void:

	var added= MainUi.camp.replenish_field()

	if added > 0:
		MainUi.show_message("Added %d hidden discs to the field." % added)
	else:
		MainUi.show_message("The field is already stocked.")
		
		
func _on_upgrade_pressed(upgrade_id) -> void:

	if MainUi.camp.buy_upgrade(upgrade_id):
		# Uses MainUI to send the message to hud
		MainUi.show_message("Purchased: %s!" % Progression.get_upgrade_name(upgrade_id))
	else:
		MainUi.show_message("Cannot buy this upgrade.")
		refresh_upgrade_buttons()

# Cheks if upgrades can be bought with current money, using Progression
func refresh_upgrade_buttons() -> void:
	for upgrade_id in upgrade_buttons:
		var button = upgrade_buttons[upgrade_id]

		var upgrade_name= Progression.get_upgrade_name(upgrade_id)
		var level = Progression.get_upgrade_level(upgrade_id)

		if Progression.is_maxed(upgrade_id):
			button.text = "%s — MAX %d/%d" % [upgrade_name, level, Progression.MAX_UPGRADE_LEVEL]
			button.disabled = true
		else:
			var cost = Progression.get_upgrade_cost(upgrade_id)

			button.text = "%s %d/%d — Buy: %d" % [upgrade_name, level, Progression.MAX_UPGRADE_LEVEL, cost]

			button.disabled = not Progression.can_buy_upgrade(upgrade_id)
			
			
func _on_upgrade_purchased(_upgrade_id) -> void:
	refresh_upgrade_buttons()
	refresh_tournament_ui()
	
func refresh_tournament_ui() -> void:
	tournament_button.text = "Enter tournament - %d coins" % (Progression.TOURNAMENT_COST)
	
	tournament_button.disabled = not Progression.can_enter_tournament()

func _on_tournament_pressed() -> void:
	if not self.visible:
		return
	Progression.enter_tournament()

func close_menu() -> void:
	MainUi.close_menus()
