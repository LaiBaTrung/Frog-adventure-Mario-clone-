extends Area2D
@onready var game_manager = %"game manager"
func _on_body_entered(body: Node2D) -> void:
	if (body.name=="Ninja Frog"):
		if body.has_method("knockback"):
				body.knockback(	)
		
		
