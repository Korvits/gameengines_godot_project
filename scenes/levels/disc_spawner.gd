class_name DiscSpawner
extends Node2D

@export var disc_scene: PackedScene
var disc_count = 13

@onready var spawn_zone = $SpawnZone/Area

var _discs = []

func add_disc(disc) -> void:
	_discs.append(disc)
	
func remove_disc(disc) -> void:
	_discs.erase(disc)

func _ready() -> void:
	
	for index in disc_count:
		spawn_disc("Lost disc %d" % (index + 1))

# Gets the size and position from Spawnzone/Area object
func get_spawn_rect() -> Rect2:
	var shape_rect = spawn_zone.shape.get_rect()
	shape_rect.position += spawn_zone.position
	return shape_rect
		
func spawn_disc(disc_name) -> void:
	var spawn_area = get_spawn_rect()
	var disc = disc_scene.instantiate()
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	disc.position = Vector2(
		random.randf_range(spawn_area.position.x,spawn_area.end.x),
		random.randf_range(spawn_area.position.y,spawn_area.end.y)
		)

	disc.disc_name = disc_name
	add_child(disc)
	
func replenish_discs() -> int:
	var remaining = get_remaining_disc_count()
	var amount_to_spawn = maxi(disc_count - remaining, 0)
	for index in range(amount_to_spawn):
		spawn_disc("Lost disc %d" % (index + 1))

	return amount_to_spawn


func get_remaining_disc_count() -> int:
	return len(_discs)

# Used for the scanner gadget
func get_hidden_discs_near(center, scan_range) -> Array[LostDisc]:
	var results: Array[LostDisc] = [] 

	for disc in _discs:

		if disc.is_queued_for_deletion():
			continue

		if disc.state != LostDisc.State.HIDDEN:
			continue

		var distance: float = center.distance_to(disc.global_position)

		if distance <= scan_range:
			results.append(disc)

	return results
