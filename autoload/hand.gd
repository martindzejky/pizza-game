extends Node

# stores global state about what is currently being carried in hand

const Z_INDEX = 100

var carrying: Pickable


func pick(node: Pickable):
    if carrying:
        print("Tried to carry two things at once")
        return

    carrying = node

    node.isPicked = true
    if node.has_signal("picked"):
        node.emit_signal("picked")

    if "z_index" in node:
        node.z_index += Z_INDEX

    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func drop():
    # Wait for the next frame to drop the node. That is so in the current frame other nodes
    # can react to the fact that the node is still being carried.
    await get_tree().create_timer(0).timeout

    carrying.isPicked = false
    if carrying.has_signal("dropped"):
        carrying.emit_signal("dropped")

    if "z_index" in carrying:
        carrying.z_index -= Z_INDEX

    # move the node to the end of the list of children so it is rendered on top
    var parent = carrying.get_parent()
    if parent:
        parent.move_child(carrying, -1)

    carrying = null

    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func isEmpty() -> bool:
    return not carrying

func isCarryingDoughTool() -> bool:
    return carrying and carrying.is_in_group("dough-tool")
