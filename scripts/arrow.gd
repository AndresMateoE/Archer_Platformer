extends Area2D

var speed = 150
var arrow_gravity = 40


func _ready():
	set_as_top_level(true)   #quiero que siempre este arriba el sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = arrow_gravity * delta
	velocity += arrow_gravity * delta
	
	position.x += ((Vector2.RIGHT).rotated(rotation)*speed).x * delta
	position.y += (((Vector2.RIGHT).rotated(rotation)*speed).y + velocity) * delta
	
	gravity(delta)

	
func gravity(delta):
	position.y += arrow_gravity * delta
	


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func arrow():
	pass
