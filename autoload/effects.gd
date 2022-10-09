extends Node

# Handles special effects for the game.

func wiggle(node: Node) -> void:
    if not node.is_inside_tree(): return

    var tween = node.create_tween()
    if not tween: return

    # if there's a sprite, wiggle it instead
    if node.has_node("sprite"):
        node = node.get_node("sprite")

    if node.has_meta("wiggle"):
        var old = node.get_meta("wiggle")
        if old.has_method("kill"):
            old.kill()

    node.set_meta("wiggle", tween)

    tween.tween_property(node, "scale", Vector2(0.96, 1.08), 0.07).from(Vector2(1, 1))
    tween.tween_property(node, "scale", Vector2(1.08, 0.96), 0.05).from_current()
    tween.tween_property(node, "scale", Vector2(0.98, 1.04), 0.03).from_current()
    tween.tween_property(node, "scale", Vector2(1, 1), 0.01).from_current()


func swing(node: Node) -> void:
    if not node.is_inside_tree(): return

    # if there's a sprite, swing it instead
    if node.has_node("sprite"):
        node = node.get_node("sprite")

    # meta to track swings
    var swings = node.get_meta("swing")

    if swings == null:
        swings = 0

    node.set_meta("swing", swings + 1)

    node.rotation = -1
    await get_tree().create_timer(0.1).timeout

    var swingsAfterWait = node.get_meta("swing")
    if swingsAfterWait <= 1:
        # reset rotation only in the last swing effect
        node.rotation = 0

    node.set_meta("swing", swingsAfterWait - 1)


func sound(name: String) -> void:
    if not Sounds or not Sounds.is_inside_tree(): return

    if Sounds.has_node(name):
        Sounds.get_node(name).play()
