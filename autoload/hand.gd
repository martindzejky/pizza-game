extends Node

# stores global state about what is currently being carried in hand

var carring: Node


func pick(node: Node):
    carring = node

func drop():
    # Wait for the next frame to drop the node. That is so in the current frame other nodes
    # can react to the fact that the node is being dropped.
    await get_tree().create_timer(0)
    carring = null

func isEmpty() -> bool:
    return not carring
