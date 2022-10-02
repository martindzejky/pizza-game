extends Node

# Handles special effects for the game.

func wiggle(node: Node) -> void:
    if not node.is_inside_tree(): return

    var tween = node.create_tween()
    if not tween: return

    tween.tween_property(node, "scale", Vector2(0.95, 1.08), 0.1).from_current()
    tween.tween_property(node, "scale", Vector2(1.08, 0.95), 0.1).from_current()
    tween.tween_property(node, "scale", Vector2(0.98, 1.04), 0.06).from_current()
    tween.tween_property(node, "scale", Vector2(1.04, 0.98), 0.06).from_current()
