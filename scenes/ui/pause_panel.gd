extends Panel

@export var resume_button: Button
@export var quit_button: Button


func _ready() -> void:
	MainUi.pause_panel = self
	self.hide()

	resume_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	

func _on_continue_pressed() -> void:
	MainUi.close_menus()

func _on_quit_pressed() -> void:
	get_tree().quit()
