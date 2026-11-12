class_name LostDisc
extends Area2D

signal collected(disc_name)

enum State {
	HIDDEN,
	REVEALED,
	COLLECTED
}

var state = State.HIDDEN
var data = null
var scanner_marker_time = 0.0
var spawner = null
var disc_name = "Disc"

@onready var sprite = $Sprite2D

func _ready() -> void:
	sprite.hide()
	spawner = get_parent()
	spawner.add_disc(self)
	#reveal()


func reveal() -> void:
	if state != State.HIDDEN:
		return

	data = create_disc_data()
	state = State.REVEALED
	
	scanner_marker_time = 0.0
	queue_redraw()

	#print("Revealed: ", data.disc_name," | ", data.get_rarity_name()," | Value: ", data.value)


func collect() -> bool:
	if state != State.REVEALED:
		return false

	if not Backpack.try_add(data):
		return false

	state = State.COLLECTED

	#print("Collected: ", data.disc_name)
	spawner.remove_disc(self)
	collected.emit(data.disc_name)

	queue_free()
	return true

# Called only after the disc has been revealed
func create_disc_data() -> DiscData:
	var result = DiscData.new()
	result.disc_name = disc_name

	var weights= Progression.get_rarity_weights()

	var common_limit = weights[0]
	var uncommon_limit = common_limit + weights[1]
	var rare_limit = uncommon_limit + weights[2]

	var roll = randi_range(1, 100)

	if roll <= common_limit:
		result.rarity = DiscData.Rarity.COMMON
		result.value = 5
	elif roll <= uncommon_limit:
		result.rarity = DiscData.Rarity.UNCOMMON
		result.value = 12
	elif roll <= rare_limit:
		result.rarity = DiscData.Rarity.RARE
		result.value = 25
	else:
		result.rarity = DiscData.Rarity.EPIC
		result.value = 60

	return result

# Draws the scanner marker if the disc is hidden
func show_scanner_marker(duration: float) -> void:
	if state != State.HIDDEN:
		return

	scanner_marker_time = duration
	queue_redraw()


func _process(delta: float) -> void:
	if scanner_marker_time <= 0.0:
		return

	scanner_marker_time = maxf(
		scanner_marker_time - delta,
		0.0
	)

	queue_redraw()

# Made with the help of AI
# Couldnt find a good sprite for my discs and I didn't have much time.
func _draw() -> void:
	if state == State.REVEALED and data != null:
		draw_disc(data.get_rarity_color())
		return

	if state == State.HIDDEN and scanner_marker_time > 0.0:
		draw_arc(
			Vector2.ZERO,
			18.0,
			0.0,
			TAU,
			32,
			Color(0.2, 0.9, 1.0),
			2.0,
			true
		)

# Made with the help of AI
func draw_disc(color: Color) -> void:
	# Small shadow underneath.
	draw_circle(
		Vector2(1, 3),
		13.0,
		Color(0, 0, 0, 0.25)
	)

	# Dark outside edge.
	draw_circle(
		Vector2.ZERO,
		13.0,
		Color("#17202b")
	)

	# Main colored surface.
	draw_circle(
		Vector2.ZERO,
		11.0,
		color
	)

	# Inner rim.
	draw_arc(
		Vector2.ZERO,
		8.0,
		0.0,
		TAU,
		32,
		color.darkened(0.3),
		1.5,
		true
	)

	# Highlight along the upper-left edge.
	draw_arc(
		Vector2.ZERO,
		9.0,
		deg_to_rad(205.0),
		deg_to_rad(285.0),
		16,
		color.lightened(0.6),
		2.0,
		true
	)
