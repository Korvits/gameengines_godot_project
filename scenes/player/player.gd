extends CharacterBody2D


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

	velocity = direction * Progression.get_move_speed()
	move_and_slide()
