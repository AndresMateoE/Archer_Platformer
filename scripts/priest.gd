extends CharacterBody2D






func _on_area_2d_body_entered(body):
	if body has_method("arrow")
		body.get_parent().queue_free()
	queue_free()
