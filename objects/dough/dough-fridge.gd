extends Node2D


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
				if !event.pressed:
					viewport.set_input_as_handled()
					queue_free()
