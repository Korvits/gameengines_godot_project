extends Node

signal camp_availability_changed

var pause_panel = null
var camp_panel = null
var backpack_panel = null
var victory_panel = null
var hud = null
var camp = null

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Backpack.pickup_failed.connect(show_message)
	Backpack.item_added.connect(_on_item_added)
	Progression.run_won.connect(show_victory)

func _input(event):
	if Progression.run_finished:
		return
		
	if event.is_action_pressed("ui_cancel"):
		if are_menus_open():
			close_menus()
		else:
			open_panel(pause_panel)

		get_viewport().set_input_as_handled()
		return

	if pause_panel.visible:
		return

	if event.is_action_pressed("open_backpack"):
		if camp_panel.visible:
			return

		if backpack_panel.visible:
			close_menus()
		else:
			open_panel(backpack_panel)
	
	if event.is_action_pressed("interact"):
		if camp_panel.visible:
			close_menus()
		elif not backpack_panel.visible:
			if camp != null and camp.player_inside:
				open_panel(camp_panel)
				backpack_panel.refresh_inventory()

		get_viewport().set_input_as_handled()
		
func show_message(message):
	hud.show_message(message)

func open_panel(panel) -> void:
	if Progression.run_finished:
		return	
		
	panel.visible = true
	hud.refresh_camp_prompt()
	get_tree().paused = true
	

func _on_item_added(item: DiscData) -> void:
	show_message("Found %s: %s — sale value %d" % [
	item.get_rarity_name(),
	item.disc_name,
	Progression.get_sale_value(item.value)
	]
)

func is_player_in_camp() -> bool:
	return camp.player_inside

func are_menus_open() -> bool:
	return (camp_panel.visible or pause_panel.visible or backpack_panel.visible)

func show_victory():
	backpack_panel.hide()
	camp_panel.hide()
	pause_panel.hide()
	
	hud.camp_prompt.hide()
	hud.message_label.text = ""
	
	var total_seconds = int(Progression.run_seconds)
	var minutes= int (total_seconds / 60.0)
	var seconds = total_seconds & 60
	
	victory_panel.victory_stats_label.text = ("Active time: %02d:%02d\n" + "Discs collected: %d\n"
		) % [minutes, seconds, Progression.discs_collected]
	
	victory_panel.show()
	get_tree().paused = true

func close_menus() -> void:
	if victory_panel.visible:
		return
	
	camp_panel.hide()
	backpack_panel.hide()
	pause_panel.hide()
	
	get_tree().paused = false
	hud.refresh_camp_prompt()
