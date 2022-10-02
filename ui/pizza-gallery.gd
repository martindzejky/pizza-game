extends GridContainer

# Displays all pizzas made in the day in a nice grid gallery.

@export var pictureObj: PackedScene


func _ready():
    for pizza in Pizzas.get_children():
        var picture = pictureObj.instantiate()

        Pizzas.remove_child(pizza)
        picture.get_node("container/center").add_child(pizza)

        var stars = picture.get_node("rating/center/stars")
        stars.region_rect.size.x = floor(pizza.score * 16)
