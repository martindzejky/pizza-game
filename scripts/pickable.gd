extends Node2D
class_name Pickable


@export var isPicked := false


func _process(delta):
    if isPicked:
        global_position = get_global_mouse_position()
