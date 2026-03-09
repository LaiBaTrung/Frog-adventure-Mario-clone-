extends Node
@onready var pause_menu: Panel = $pause_menu

func _process(delta: float) -> void:
	var esc_pressed=Input.is_action_just_pressed("pause")
	if (esc_pressed== true):
		get_tree().paused=true
		pause_menu.show()
	

func _on_resume_pressed() -> void:
	pause_menu.hide()
	get_tree().paused = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scences/Menu.tscn")
