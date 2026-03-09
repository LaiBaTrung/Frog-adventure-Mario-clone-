extends Area2D

@onready var game_manager: Node = %"game manager"
@onready var fruit_collect: AudioStreamPlayer = $fruit_collect

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Ninja Frog":
		return

	game_manager.add_points()
	fruit_collect.play()

	# safely disable collider and hide sprite
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.hide()

	# wait until the sound finishes before freeing
	await fruit_collect.finished
	queue_free()
