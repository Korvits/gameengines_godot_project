class_name DiscScanner
extends Node2D

signal status_changed

const COOLDOWN_SECONDS = 6.0
const MARKER_SECONDS = 2.0

@export var spawner: DiscSpawner
var cooldown_remaining = 0.0


func _ready() -> void:
	Progression.upgrade_purchased.connect(_on_upgrade_purchased)
	

func _physics_process(delta: float) -> void:
	var previous_seconds = ceili(cooldown_remaining)

	cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)

	if ceili(cooldown_remaining) != previous_seconds:
		status_changed.emit()

	if Input.is_action_just_pressed("use_gadget"):
		try_scan()


func try_scan() -> void:
	if not Progression.has_scanner():
		return

	if cooldown_remaining > 0.0:
		return

	if spawner == null:
		return

	# Gets nearby discs from the spawner itself
	var nearby = spawner.get_hidden_discs_near(global_position, Progression.get_scanner_range())

	for disc in nearby:
		disc.show_scanner_marker(MARKER_SECONDS)

	cooldown_remaining = COOLDOWN_SECONDS
	status_changed.emit()


func _on_upgrade_purchased(upgrade_id) -> void:
	if upgrade_id == "scanner":
		status_changed.emit()
