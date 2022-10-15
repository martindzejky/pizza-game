extends Node2D

# spawns generated pizzas

@export var pizzaObj: PackedScene

func createPizza():
    var pizza = pizzaObj.instantiate()
    add_child(pizza)
