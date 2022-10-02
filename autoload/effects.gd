extends Node

# Handles special effects for the game.

func wiggle(node: Node) -> void:
    if not node.is_inside_tree(): return

    var tween = node.create_tween()
    if not tween: return

    # if there's a sprite, wiggle it instead
    if node.has_node("sprite"):
        node = node.get_node("sprite")

    tween.tween_property(node, "scale", Vector2(-0.04, 0.08), 0.1).from_current().as_relative()
    tween.tween_property(node, "scale", Vector2(0.08, -0.04), 0.1).from_current().as_relative()
    tween.tween_property(node, "scale", Vector2(-0.02, 0.04), 0.06).from_current().as_relative()
    tween.tween_property(node, "scale", Vector2(0.04, -0.02), 0.06).from_current().as_relative()
    tween.tween_property(node, "scale", Vector2(1, 1), 0.02).from_current()
