extends Node2D
class_name Pickable


signal picked
signal dropped


@export var isPicked := false
@export var offset := Vector2()


func _process(delta):
    if isPicked:
        global_position = get_global_mouse_position() + offset
