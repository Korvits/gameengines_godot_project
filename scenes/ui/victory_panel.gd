extends Panel

@export var victory_stats_label: Label

@export var play_again_button: Button

func _ready() -> void:
	MainUi.victory_panel = self
	self.hide()

	play_again_button.pressed.connect(_on_play_again_pressed)


func _on_play_again_pressed() -> void:
	play_again_button.disabled = true

	Backpack.items.clear()
	Progression.reset_run()

	get_tree().paused = false

	get_tree().reload_current_scene()
