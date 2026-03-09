extends CharacterBody2D
@onready var game_manager = %"game manager"
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

# Movement constants
const SPEED = 250.0
const JUMP_VELOCITY = -460.0
const DOUBLE_JUMP_VELOCITY = -400.0  # Slightly weaker second jump
const Gravity = 1700	
const Low_gravity = 1700.0 * 0.95
const DEATH_DELAY = 1
const INVINCIBLE_MAX = 0.3
const coyote_time_max = 0.10
const buffer_jump_max = 0.10

# State variables
var invincible_time = 0.0
var knockback_vec = Vector2.ZERO
var is_knocked_back = false
var is_dead = false
var death_timer = 0.0
var coyote_time = 0.0
var buffer_jump = 0.0

# Double jump animation variables
var double_jump_anim_timer = 0.0  # Timer for double jump animation
var double_jump_anim_duration = 0.3  # How long to show double jump animation

# Double jump variables
var jumps_remaining = 2  # Total jumps available (1 regular + 1 double)
var max_jumps = 2

func jump():
	if is_dead or jumps_remaining <= 0:
		return
	
	# Use different velocity for double jump
	if jumps_remaining == max_jumps:
		velocity.y = JUMP_VELOCITY  # First jump
	else:
		velocity.y = DOUBLE_JUMP_VELOCITY  # Double jump
		# Set double jump animation and timer
		sprite_2d.animation = "double_jump"  # Change this to match your animation name
		double_jump_anim_timer = double_jump_anim_duration
	
	jumps_remaining -= 1
	$jump_sfx.play()

func knockback(strength: float = 250.0, up_force: float = -200.0):
	if invincible_time > 0 or is_dead:
		return
	invincible_time = INVINCIBLE_MAX
	is_knocked_back = true
	sprite_2d.animation = "hit"
	game_manager.decrease_health()
	if game_manager.lives > 0:
		$get_hit.play()
	if game_manager.lives <= 0:
		if $explosion.stream:
			$explosion.play()
		sprite_2d.hide()
		is_dead = true
		death_timer = 0.0
	var dir = -1 if sprite_2d.flip_h else 1
	knockback_vec = Vector2(dir * -strength, up_force)

func _process(delta):
	if is_dead:
		death_timer += delta
		if death_timer >= DEATH_DELAY:
			get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.y += Gravity * delta
		move_and_slide()
		return
	
	var gravity_now = Gravity
	
	# Update double jump animation timer
	if double_jump_anim_timer > 0:
		double_jump_anim_timer -= delta
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not is_knocked_back:
			# Only change to Jump animation if not playing double jump animation
			if double_jump_anim_timer <= 0:
				sprite_2d.animation = "Jump"
	else:
		# Reset jumps when touching the ground
		jumps_remaining = max_jumps
		double_jump_anim_timer = 0.0  # Reset animation timer on ground
	
	if invincible_time > 0:
		invincible_time -= delta
	
	if is_knocked_back:
		velocity = knockback_vec
		knockback_vec = knockback_vec.lerp(Vector2.ZERO, 0.1)
		if knockback_vec.length() < 10:
			is_knocked_back = false
	else:
		if not is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, 0.1)
		
		coyote_time = coyote_time_max if is_on_floor() else max(coyote_time - delta, 0.0)
		buffer_jump = buffer_jump_max if Input.is_action_just_pressed("jump") else max(buffer_jump - delta, 0.0)
		
		# Modified jump condition to work with double jump
		if buffer_jump > 0.0 and (jumps_remaining > 0):
			# Allow jump if: on floor, coyote time, or have double jump remaining
			if is_on_floor() or coyote_time > 0.0 or jumps_remaining < max_jumps:
				jump()
				buffer_jump = 0.0
				if is_on_floor() or coyote_time > 0.0:
					coyote_time = 0.0
		
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= 0.4
		
		gravity_now = Low_gravity if abs(velocity.y) < 50 and velocity.y < 0 else Gravity
		
		var direction := Input.get_axis("left", "right")
		velocity.x = direction * SPEED if direction != 0 else move_toward(velocity.x, 0, 15)
	
	move_and_slide()
	
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0
	
	if not is_knocked_back and is_on_floor():
		# Only change ground animations if not playing double jump animation
		if double_jump_anim_timer <= 0:
			sprite_2d.animation = "idle" if velocity.x == 0 else "run"
