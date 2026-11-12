extends Node2D

var search_duration: float:
	get:
		return Progression.get_search_duration()
@export var pickup_distance = 36.0

@onready var search_area: Area2D = $SearchArea
@onready var search_shape: CircleShape2D = $SearchArea/CollisionShape2D.shape
@onready var progress_bar: ProgressBar = $SearchProgress

var target: LostDisc = null
var search_elapsed = 0.0
var waiting_for_release = false


func _ready() -> void:
	progress_bar.max_value = search_duration
	progress_bar.step = 0.01
	progress_bar.hide()


func _physics_process(delta: float) -> void:
	progress_bar.max_value = search_duration
	
	if not Input.is_action_pressed("search"):
		waiting_for_release = false
		reset_search()
		return

	if waiting_for_release:
		return

	# Collect the disc if it has already been revealed
	var pickup = find_nearest_disc(LostDisc.State.REVEALED,pickup_distance)

	if pickup != null:
		if pickup.has_method("collect"):
			pickup.collect()
		waiting_for_release = true
		reset_search()
		return

	
	
	var nearest = find_nearest_disc(LostDisc.State.HIDDEN, search_shape.radius)

	if nearest != target:
		reset_search()
		target = nearest

	if target == null:
		reset_search()
		return

	search_elapsed += delta

	progress_bar.show()
	progress_bar.value = search_elapsed

	# Reveal disc after searching time 
	if search_elapsed >= search_duration:
		if target.has_method("reveal"):
			target.reveal()
		waiting_for_release = true
		reset_search()

# Had some help from AI here
func find_nearest_disc(required_state: int,maximum_distance: float) -> LostDisc:
	var nearest: LostDisc = null
	var nearest_distance: float = maximum_distance

	for area in search_area.get_overlapping_areas():
		var disc := area as LostDisc

		if disc == null:
			continue

		if disc.state != required_state:
			continue

		var distance := global_position.distance_to(disc.global_position)

		if distance <= nearest_distance:
			nearest = disc
			nearest_distance = distance

	return nearest


func reset_search() -> void:
	target = null
	search_elapsed = 0.0
	progress_bar.value = 0.0
	progress_bar.hide()
