extends Node2D


@export var doughObject: PackedScene


func _onClick() -> bool:
    if not Hand.isEmpty(): return false

    # destroy this object
    queue_free()

    # spawn a new dough that is picked
    var dough = doughObject.instantiate()
    get_tree().call_group("table", "add_child", dough)
    Hand.pick(dough)

    return true
