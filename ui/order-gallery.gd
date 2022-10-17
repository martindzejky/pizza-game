extends Control

# Displays failed orders in the gallery.


func _ready():
    var orderCount = Orders.get_child_count()
    if orderCount == 0:
        # no failed orders!!!
        $none.show()

    # calculate whether we need to squash the orders
    var width = get_size().x
    var maxOrders = floor(width / 30)

    var counter = 0
    for order in Orders.get_children():
        # remove from parent
        Orders.remove_child(order)

        # add to this node
        add_child(order)

        # set correct position

        if orderCount < maxOrders:
            # no need to squash
            order.position.y = 15
            order.position.x = 12 + counter * 30
        else:
            # squash
            order.position.y = 15 + randf_range(-3, 3)
            order.position.x = 12 + counter * 8

        counter += 1
