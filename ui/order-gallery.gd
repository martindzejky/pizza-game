extends Control

# Displays failed orders in the gallery.

@export var pictureObj: PackedScene


func _ready():
    if Orders.get_child_count() == 0:
        # no failed orders!!!
        $none.show()
        return

    for order in Orders.get_children():
        var picture = pictureObj.instantiate()

        # add the order
        Orders.remove_child(order)
        picture.get_node("container/center").add_child(order)

        add_child(picture)
