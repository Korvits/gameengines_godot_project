extends Control

@export var summary_label: Label
@export var gadget_label: Label
@export var money_label: Label

@export var message_label: Label
@export var camp_prompt: Label
@export var camp_prompt_panel: Panel
@export var controls_label: Label
@export var field_count_label: Label

@export var disc_spawner: DiscSpawner
@export var scanner: DiscScanner


var message_time_left = 0.0

func _ready() -> void:
	MainUi.hud = self
	
	message_label.text = ""
	
	MainUi.camp_availability_changed.connect(refresh_camp_prompt)
	Backpack.inventory_changed.connect(refresh_inventory)
	Progression.money_changed.connect(refresh_money)
	scanner.status_changed.connect(refresh_gadget)
	
	refresh_gadget()
	refresh_inventory()
	refresh_money()
	
func _process(delta: float) -> void:
	
	refresh_field_count()
	
	if message_time_left > 0.0:
		message_time_left -= delta

		if message_time_left <= 0.0:
			message_label.text = ""
		
	
	if Input.is_action_just_pressed("toggle_controls"):
		var visibility = !controls_label.visible
		controls_label.set_visible(visibility)
	
func refresh_inventory() -> void:
	var count = Backpack.items.size()
	var total = Backpack.get_total_value()
	
	summary_label.text = "Backpack: %d / %d \nValue: %d" % [count,Backpack.capacity,total]

	if Backpack.is_full():
		summary_label.text += "   FULL"
		
func refresh_money() -> void:
	money_label.text = "Money: %d" % Progression.money
	
func refresh_camp_prompt() -> void:
	# To make the camp prompt disappear when a menu is open
	var visibility = false
	if MainUi.are_menus_open():
		visibility = false
	else:
		visibility = MainUi.is_player_in_camp()
	camp_prompt.visible = visibility
	camp_prompt_panel.visible = visibility
	
func hide_camp_prompt() -> void:
	camp_prompt.visible = false
	camp_prompt_panel.visible = false

func show_message(message) -> void:
	message_label.text = message
	message_time_left = 2.5

func refresh_field_count() -> void:
	var remaining = disc_spawner.get_remaining_disc_count()

	field_count_label.text = "Discs left: %d" % remaining

func refresh_gadget() -> void:
	if not Progression.has_scanner():
		gadget_label.text = "Gadget: Empty"
		return

	if scanner.cooldown_remaining > 0.0:
		# Has direct link to scanner to get the live cooldown
		gadget_label.text = "Gadget: Scanner — ready in %ds" % (ceili(scanner.cooldown_remaining))
	else:
		gadget_label.text = "Gadget: Scanner — Q to scan"
