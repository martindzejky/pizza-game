extends Node

# Called when the level is loaded. Reset the global state.

func _ready():
    for node in Pizzas.get_children():
        Pizzas.remove_child(node)
    for node in Orders.get_children():
        Orders.remove_child(node)
