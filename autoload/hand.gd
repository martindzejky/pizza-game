extends Node2D

# Stores global state about what is currently being carried in hand.
# Items currently in hand are move as children of this node.


func _init():
    # increase the z-index to render the items in hand above everything else
    z_index = 10


func pick(node: Pickable) -> void:

    node.isPicked = true
    if node.has_signal("picked") and node.is_inside_tree():
        node.emit_signal("picked")

    # random offset if already carrying some items
    if not Hand.isEmpty():
        node.offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
    else:
        node.offset = Vector2()

    # move the node to this node
    var globalTransform = node.get_global_transform()
    if node.get_parent():
        node.get_parent().remove_child(node)
    add_child(node)
    node.set_global_transform(globalTransform)

    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

    if not node.is_in_group("tool"):
        Effects.wiggle(node)

    print("Picked up ", node)



func drop() -> Pickable:
    if isEmpty():
        print("Tried to drop nothing, the hand is empty")
        return

    # get the last item in hand (children) and drop it

    var item = get_children().pop_back()
    if not item:
        push_error("isEmpty() returned false but the last child does not exist! There's a bug somwhere...")
        return

    item.isPicked = false
    if item.has_signal("dropped"):
        item.emit_signal("dropped")

    # move back to table node
    var globalTransform = item.get_global_transform()
    remove_child(item)
    get_tree().call_group("table", "add_child", item)
    item.set_global_transform(globalTransform)

    # Wait for the next frame to drop the node. That is so in the current frame other nodes
    # can react to the fact that the node is still being carried.
    # TODO: disabled because it seems unnecessary
    # await get_tree().create_timer(0).timeout

    if isEmpty():
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if not item.is_in_group("tool"):
        Effects.wiggle(item)

    print("Dropped ", item)

    return item


func reset() -> void:
    for child in get_children():
        remove_child(child)



func isEmpty() -> bool:
    return get_child_count() == 0

func isCarryingMultipleItems() -> bool:
    return get_child_count() > 1

func isCarryingDough() -> bool:
    for child in get_children():
        if child.is_in_group("dough"):
            return true
    return false

func isCarryingDoughTool() -> bool:
    for child in get_children():
        if child.is_in_group("dough-tool"):
            return true
    return false

func isCarryingSpoon() -> bool:
    for child in get_children():
        if child.is_in_group("spoon"):
            return true
    return false

func isCarryingIngredient(group = "ingredient") -> bool:
    if isEmpty(): return false

    for child in get_children():
        if child.is_in_group(group):
            continue
        return false

    # all items matched the group
    return true

func getCarriedItem() -> Node:
    if isEmpty(): return null
    return get_children().pop_back()





# --------------------
# Click handing. Custom implementation because Godot's click events are not ordered (seem random, probably a bug?).
# https://github.com/godotengine/godot/issues/23051
# --------------------


func _unhandled_input(event: InputEvent) -> void:

    # only care about left mouse clicks (on release)
    if not event is InputEventMouseButton: return
    if event.button_index != MOUSE_BUTTON_LEFT: return
    if not event.is_pressed(): return

    # get global mouse position
    var mousePos = get_viewport().get_mouse_position()

    var clickNodes = get_tree().get_nodes_in_group("click").duplicate()
    clickNodes.reverse()

    for node in clickNodes:
        if not node.is_inside_tree(): continue

        if not node.has_node("clickArea"):
            push_warning("node in 'click' group has no clickArea: ", node)
            continue

        var clickArea = node.get_node("clickArea")
        if not clickArea:
            push_warning("node in 'click' group has no clickArea: ", node)
            continue

        var owners = clickArea.get_shape_owners()
        if owners.size() == 0:
            push_warning("node in 'click' group has no shape owners: ", clickArea)
            continue

        var shapeCount = clickArea.shape_owner_get_shape_count(owners[0])
        if shapeCount < 1:
            push_warning("node in 'click' group has no shapes: ", clickArea)
            continue

        var shape = clickArea.shape_owner_get_shape(owners[0], 0)
        if not shape:
            push_warning("node in 'click' group has no shape: ", clickArea)
            continue


        # LIMITATION
        # supports only one shape per node!


        var shapeTransform = clickArea.shape_owner_get_transform(owners[0])

        if shape is CircleShape2D:
            var position = clickArea.global_position + shapeTransform.origin
            var distanceToMouse = position.distance_to(mousePos)

            if distanceToMouse > shape.radius:
                continue

        elif shape is RectangleShape2D:
            var rect = Rect2()
            rect.position = clickArea.global_position + shapeTransform.origin - shape.size/2
            rect.size = shape.size

            if not rect.has_point(mousePos):
                continue

        else:
            push_warning("node in 'click' group has unsupported shape: ", shape)


        var result = false

        print("Click on ", node)
        if node.has_method("_onClick"):
            result = node._onClick()
        else:
            push_warning("node in 'click' group has no _onClick method: ", node)

        # if the node handled the click event, stop here
        if result:
            break
