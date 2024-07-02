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
@onready var arrow = preload("res://scenes/arrow.tscn")
@onready var bow_marker = $Bow_Marker

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
	
	if  is_on_floor():
		JUMPS = TOTAL_JUMPS
		if direction == 0:
			animated_sprite.play("idle")
		else: 
			animated_sprite.play("run")
	else:
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
	$Bow_Marker.look_at(mouse_pos)
	shoot()

func shoot():
	if Input.is_action_just_pressed("shoot"):
		var arrow_instance = arrow.instantiate()
		get_parent().add_child(arrow_instance)
		arrow_instance.global_position = $Bow_Marker.global_position
		arrow_instance.rotation = $Bow_Marker.rotation

#Timer para coyote time
func _on_coyote_timer_timeout():
	coyote = false



