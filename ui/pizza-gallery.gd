extends GridContainer

# Displays all pizzas made in the day in a nice grid gallery.

@export var pictureObj: PackedScene


func _ready():
    if Pizzas.get_child_count() == 0:
        # no pizzas made
        $none.show()
        columns = 1
        return

    for pizza in Pizzas.get_children():
        var picture = pictureObj.instantiate()

        # add the pizza
        Pizzas.remove_child(pizza)
        picture.get_node("container/center").add_child(pizza)

        # move the order if there is any
        for child in pizza.get_children():
            if child.is_in_group("order-success"):
                pizza.remove_child(child)
                picture.get_node("container/center/order").add_child(child)

        # set the correct rating
        var stars = picture.get_node("rating/center/stars")
        stars.region_rect.size.x = floor(pizza.score * 16)

        add_child(picture)
