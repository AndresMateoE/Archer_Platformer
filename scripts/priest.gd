extends Area2D




func _on_area_entered(area):
	if area.has_method("arrow"):
		area.queue_free()
		queue_free()# Replace with function body.
#func _on_area_2d_body_entered(body):
