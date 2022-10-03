extends Node

# stores global state about what is currently being carried in hand

var carrying: Pickable


func pick(node: Pickable) -> void:
    if carrying:
        print("Tried to carry two things at once, already carrying ", carrying)
        return

    carrying = node
    print("Picked up ", node)

    node.isPicked = true
    if node.has_signal("picked") and node.is_inside_tree():
        node.emit_signal("picked")

    # move to hand node to be rendered on top
    var globalTransform = node.get_global_transform()
    if node.get_parent():
        node.get_parent().remove_child(node)
    get_tree().call_group("hand", "add_child", node)
    node.set_global_transform(globalTransform)

    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

    if not node.is_in_group("tool"):
        Effects.wiggle(node)

func drop() -> Pickable:
    if not carrying:
        print("Tried to drop nothing")
        return

    carrying.isPicked = false
    if carrying.has_signal("dropped") and carrying.is_inside_tree():
        carrying.emit_signal("dropped")

    # move back to table node
    var globalTransform = carrying.get_global_transform()
    if carrying.get_parent():
        carrying.get_parent().remove_child(carrying)
    get_tree().call_group("table", "add_child", carrying)
    carrying.set_global_transform(globalTransform)

    # Wait for the next frame to drop the node. That is so in the current frame other nodes
    # can react to the fact that the node is still being carried.
    # TODO: disabled
    # await get_tree().create_timer(0).timeout

    var wasCarrying = carrying
    carrying = null

    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if not wasCarrying.is_in_group("tool"):
        Effects.wiggle(wasCarrying)

    print("Dropped ", wasCarrying)

    return wasCarrying


func isEmpty() -> bool:
    return not carrying

func isCarryingDough() -> bool:
    return carrying and carrying.is_in_group("dough")

func isCarryingDoughTool() -> bool:
    return carrying and carrying.is_in_group("dough-tool")

func isCarryingSpoon() -> bool:
    return carrying and carrying.is_in_group("spoon")

func isCarryingIngredient() -> bool:
    return carrying and carrying.is_in_group("ingredient")





# --------------------
# Click handing. Custom implementation because Godot's click events are not ordered (seem random, probably a bug?).
# https://github.com/godotengine/godot/issues/23051


func _unhandled_input(event: InputEvent) -> void:

    # only care about left mouse clicks (on release)
    if not event is InputEventMouseButton: return
    if event.button_index != MOUSE_BUTTON_LEFT: return
    if not event.is_pressed(): return

    print("click!")

    # get global mouse position
    var mousePos = get_viewport().get_mouse_position()
    print("mousePos: ", mousePos)

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

        print("click on ", node)
        if node.has_method("_onClick"):
            result = node._onClick()
        else:
            push_warning("node in 'click' group has no _onClick method: ", node)

        # if the node handled the click event, stop here
        if result:
            break
