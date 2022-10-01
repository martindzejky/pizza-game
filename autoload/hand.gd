extends Node

# stores global state about what is currently being carried in hand

var carrying: Pickable


func pick(node: Pickable):
    if carrying:
        print("Tried to carry two things at once")
        return

    carrying = node

    node.isPicked = true
    if node.has_signal("picked"):
        node.emit_signal("picked")

    # move to hand node to be rendered on top
    var globalTransform = node.get_global_transform()
    if node.get_parent():
        node.get_parent().remove_child(node)
    get_tree().call_group("hand", "add_child", node)
    node.set_global_transform(globalTransform)

    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func drop():
    # Wait for the next frame to drop the node. That is so in the current frame other nodes
    # can react to the fact that the node is still being carried.
    await get_tree().create_timer(0).timeout

    carrying.isPicked = false
    if carrying.has_signal("dropped"):
        carrying.emit_signal("dropped")

    # move back to table node
    var globalTransform = carrying.get_global_transform()
    if carrying.get_parent():
        carrying.get_parent().remove_child(carrying)
    get_tree().call_group("table", "add_child", carrying)
    carrying.set_global_transform(globalTransform)

    carrying = null

    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func isEmpty() -> bool:
    return not carrying

func isCarryingDoughTool() -> bool:
    return carrying and carrying.is_in_group("dough-tool")
