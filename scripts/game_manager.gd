extends Node

@onready var label: Label = $"../../UI/Panel/Label"
@onready var h_box_container: HBoxContainer = $"../../UI/hearts/HBoxContainer"

@export var hearts: Array[TextureRect] = []
@export var empty_heart: Texture  # assign a transparent or grey heart here
var is_dead = false 
var points: int = 0
var lives: int = 3

func _ready():
	# Initialize hearts to match starting lives
	update_hearts()

# Call this when the frog takes damage
func decrease_health():
	if lives <= 0:
		return  # Player already dead, ignore further hits

	lives -= 1
	print("Lives left:", lives)
	update_hearts()

	if lives <=0:
		is_dead=true
	
	# Check if player died and trigger explosion
	#if lives <= 0:
		#if has_node("/root/Node2D/Ninja Frog"):  # Adjust path to your player node
			#var player = get_node("/root/Node2D/Ninja Frog")
			#if player.has_method("explosion"):
				#player.explosion()
				
# Call this when the frog gains points
func add_points():
	points += 1
	label.text = "Points: " + str(points)
	print("Points:", points)

# Update hearts UI to reflect current lives
func update_hearts():
	for i in range(hearts.size()):
		if i < lives:
			hearts[i].texture = hearts[i].texture  # keep original heart
		else:
			hearts[i].texture = empty_heart       # replace with empty heart
