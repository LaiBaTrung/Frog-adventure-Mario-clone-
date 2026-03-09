extends CharacterBody2D
@onready var game_manager = %"game manager"
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var wall_detect: RayCast2D = $wall_detect
@onready var ground_detect: RayCast2D = $ground_detect

var direction: int = -1
var speed: float = 100.0  # Add movement speed

func _ready():
	# Make sure raycasts are enabled
	wall_detect.enabled = true
	ground_detect.enabled = true
	
func _physics_process(delta):
	# Check for wall and ground collisions only (not player collisions)
	if should_turn():
		direction *= -1
		sprite_2d.flip_h = direction > 0
		flip_rays()
	
	# Apply movement
	velocity.x = direction * speed
	sprite_2d.animation='walk'
	
	# Apply gravity if you want the enemy to fall
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	move_and_slide()

func should_turn():
	# Only turn when hitting walls or reaching edges
	return wall_detect.is_colliding() or not ground_detect.is_colliding()


func _on_area_2d_body_entered(body):
	if (body.name=="Ninja Frog"):
		if body.has_method("knockback") and body.is_dead:
			return
		var y_delta = position.y - body.position.y
		if (y_delta > 20):
			print("enemy destroyed")
			queue_free()
			# Temporarily give player jumps back, then jump
			body.jumps_remaining = body.max_jumps
			body.jump()		
			game_manager.add_points()							
		else:
			print("decrease player health")
			if body.has_method("knockback"):
				body.knockback()

func flip_rays():
	# Flip wall ray
	var w = wall_detect.target_position
	w.x = abs(w.x) * direction
	wall_detect.target_position = w
	# Flip ground ray
	var g = ground_detect.target_position
	g.x = abs(g.x) * direction
	ground_detect.target_position = g
