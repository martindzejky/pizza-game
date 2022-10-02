extends Node2D

# Generates new orders EVERY 10 SECONDS #ld51

@export var orderObj: PackedScene


func _on_timer_timeout() -> void:
    var newOrder = orderObj.instantiate()
    add_child(newOrder)
