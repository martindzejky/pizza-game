extends Node

func _ready():
    for node in Pizzas.get_children():
        Pizzas.remove_child(node)
