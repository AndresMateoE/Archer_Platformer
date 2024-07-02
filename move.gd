extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -290.0
const TOTAL_JUMPS = 1
var JUMPS = TOTAL_JUMPS
var jumping = false
# Coyete time variables
var coyote = false
var coyote_frames = 6
var last_floor = false
# Shooting Variables
var shooting = false
var arrow_speed = 100
@onready var arrow = preload("res://scenes/arrow.tscn")
@onready var bow_marker_right = $Bow_Marker_Right
@onready var bow_marker_left = $Bow_Marker_Left
var bow_marker

@onready var shoot_timer = $Shoot_timer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var CoyoteTimer = $CoyoteTimer


func _ready():
	$CoyoteTimer.wait_time = coyote_frames / 60.0
	
	
func _physics_process(delta):
	
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
	if  is_on_floor() and not shooting:
		JUMPS = TOTAL_JUMPS
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
	
	
	move_and_slide()
	_on_coyote_timer_timeout()
	last_floor = is_on_floor()
	
	var mouse_pos = get_global_mouse_position()
	$Bow_Marker_Left.look_at(mouse_pos)
	$Bow_Marker_Right.look_at(mouse_pos)
	shoot()

func shoot():
	var direction = 1 if $AnimatedSprite2D.flip_h else -1
	if Input.is_action_just_pressed("shoot"):
		$Shoot_timer.start()
		shooting = true
		animated_sprite.play("bow_attack")
		
	if Input.is_action_pressed("shoot"):
		if (shoot_timer.get_time_left() < 1.5) and (shoot_timer.get_time_left() > 1):
			arrow_speed = 100
			#print("shoot2")
		elif shoot_timer.get_time_left() < 1 and shoot_timer.get_time_left() > 0.5:
			arrow_speed = 200
			#print("shoot3")
		elif shoot_timer.get_time_left() < 0.5 and shoot_timer.get_time_left() > 0.1:
			arrow_speed = 300
			#print("shoot4")
		else:
			arrow_speed = 350
	if Input.is_action_just_released("shoot"):
		var arrow_instance = arrow.instantiate()
		animated_sprite.play("bow_attack_realese")
		if direction > 0:
			get_parent().add_child(arrow_instance)
			arrow_instance.global_position = $Bow_Marker_Left.global_position
			arrow_instance.rotation = $Bow_Marker_Left.rotation
			arrow_instance.speed = arrow_speed
		if direction < 0:
			get_parent().add_child(arrow_instance)
			arrow_instance.global_position = $Bow_Marker_Right.global_position
			arrow_instance.rotation = $Bow_Marker_Right.rotation
			arrow_instance.speed = arrow_speed
		shooting = false

#Timer para coyote time
func _on_coyote_timer_timeout():
	coyote = false



