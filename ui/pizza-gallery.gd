extends GridContainer


func _ready():
    for pizza in Pizzas.get_children():
        Pizzas.remove_child(pizza)
        add_child(pizza)
