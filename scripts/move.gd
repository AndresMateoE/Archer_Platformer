extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -290.0
const TOTAL_JUMPS = 4
var JUMPS = TOTAL_JUMPS
var jumping = false
var cumulative_velocity = 0
# Coyete time variables
var coyote = false
var coyote_frames = 6
var last_floor = false
# Shooting Variables
var shooting = false
var arrow_speed = 100
var init_vel_arrow = Vector2()
var cancel_shoot = false
@onready var arrow = preload("res://scenes/arrow.tscn")
@onready var bow_marker_right = $Bow_Marker_Right
@onready var bow_marker_left = $Bow_Marker_Left

@onready var death_timer = $Death_timer
var dying = false


@onready var shoot_timer = $Shoot_timer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var CoyoteTimer = $CoyoteTimer


func _ready():
	$CoyoteTimer.wait_time = coyote_frames / 60.0
	
	
func _physics_process(delta):
	
	move(delta)
	
	move_and_slide()
	_on_coyote_timer_timeout()
	last_floor = is_on_floor()
	
	#Shoot process
	var mouse_pos = get_global_mouse_position()
	$Bow_Marker_Left.look_at(mouse_pos)
	$Bow_Marker_Right.look_at(mouse_pos)
	shoot()
	fall_death()
	

func shoot():
		
	var direction = 1 if $AnimatedSprite2D.flip_h else -1
	if Input.is_action_just_pressed("shoot"):
		$Shoot_timer.start()
		shooting = true
		animated_sprite.play("bow_attack")
		
	if Input.is_action_pressed("shoot"):
		if Input.is_action_just_pressed("cancel_shoot"):
			cancel_shoot = true
			animated_sprite.stop()
		else:
			if (get_global_mouse_position()-animated_sprite.global_position).x < 0:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
			var shoot_power = 800
			if (shoot_timer.get_time_left() < 1.5) and (shoot_timer.get_time_left() > 1):
				arrow_speed = 0.5 * shoot_power
				#print("shoot2")
			elif shoot_timer.get_time_left() < 1 and shoot_timer.get_time_left() > 0.5:
				arrow_speed = 0.7 * shoot_power
				#print("shoot3")
			elif shoot_timer.get_time_left() < 0.5 and shoot_timer.get_time_left() > 0.1:
				arrow_speed = 0.9 * shoot_power
				#print("shoot4")
			else:
				arrow_speed = 1 * shoot_power
	if Input.is_action_just_released("shoot"):
		if cancel_shoot:
			cancel_shoot = false
		else:
			var arrow_instance = arrow.instantiate()
			animated_sprite.play("bow_attack_realese")
			if direction > 0:
				get_parent().add_child(arrow_instance)
				arrow_instance.global_position = $Bow_Marker_Left.global_position
				arrow_instance.rotation = $Bow_Marker_Left.rotation
				arrow_instance.init_vel_arrow = (Vector2.RIGHT).rotated($Bow_Marker_Left.rotation)*arrow_speed
				arrow_instance.speed = arrow_speed
				arrow_instance.velocity = velocity * 0.2
			if direction < 0:
				get_parent().add_child(arrow_instance)
				arrow_instance.global_position = $Bow_Marker_Right.global_position
				arrow_instance.rotation = $Bow_Marker_Right.rotation
				arrow_instance.init_vel_arrow = (Vector2.RIGHT).rotated($Bow_Marker_Right.rotation)*arrow_speed
				#arrow_instance.init_vel_arrow= ((Vector2.RIGHT).rotated(rotation)*arrow_speed)
				arrow_instance.speed = arrow_speed
				arrow_instance.velocity = velocity * 0.2
			shooting = false
			



func move(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote):
		velocity.y = JUMP_VELOCITY
		jumping = true
		
	# Double Jump
	if Input.is_action_just_pressed("jump") and (not is_on_floor()):
		if JUMPS > 0:
			velocity.y = JUMP_VELOCITY
			JUMPS += -1
			
	# Restauro los saltos
	if !is_on_floor() and last_floor and !jumping:
		coyote = true
		jumping = false
		$CoyoteTimer.start()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	
	if direction < 0:
		animated_sprite.flip_h = true
	if direction > 0:
		animated_sprite.flip_h = false
	if is_on_floor():
		JUMPS = TOTAL_JUMPS
	
	if  is_on_floor() and not shooting and not dying:
		if direction == 0:
			animated_sprite.play("idle")
		else: 
			animated_sprite.play("run")
	elif not is_on_floor() and not shooting:
			animated_sprite.play("jump")
		
	#ataque
	if Input.is_action_just_pressed("shoot") and is_on_floor():
		animated_sprite.play("bow_attack")
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func fall_death():
	if not is_on_floor() and velocity.y > 0:
		cumulative_velocity += velocity.y
	if not is_on_floor() and velocity.y < 0:
		cumulative_velocity = 0
	if is_on_floor() and cumulative_velocity > 10000:
		print("MUERE")
		dying = true
		animated_sprite.play("death")
		death_timer.start()
		cumulative_velocity = 0

func _on_death_timer_timeout():
	dying = false
	get_tree().reload_current_scene()
#Timer para coyote time
func _on_coyote_timer_timeout():
	coyote = false
