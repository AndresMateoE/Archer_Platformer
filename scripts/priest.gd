extends Area2D




func _on_body_entered(body):
	if body.has_method("arrow"):
		body.queue_free()
		queue_free()# Replace with function body.
#func _on_area_2d_body_entered(body):
