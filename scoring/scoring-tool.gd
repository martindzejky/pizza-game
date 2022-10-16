@tool
extends Node2D

# This is a tool script which runs in the editor, used
# to tweak the scoring system and check it in real time in the editor.

# texture to use to print the score
@export var starsTexture: Texture
# if true, pizzas are scored
@export var doScore := false


func _process(delta):
    # only run in the editor
    if not Engine.is_editor_hint(): return
    update_configuration_warnings()

    if not has_node("scorer"): return

    if not doScore: return
    doScore = false
    queue_redraw()

    # find all dough and score them
    var pizzas = get_tree().get_nodes_in_group("dough")
    for pizza in pizzas:
        if not pizza.visible: continue
        var score = get_node("scorer").score(pizza, true)
        pizza.score = score


func _draw():
    # only run in the editor
    if not Engine.is_editor_hint(): return

    # find all dough and draw their score
    var pizzas = get_tree().get_nodes_in_group("dough")
    for pizza in pizzas:
        if not pizza.visible: continue
        var position = Vector2(pizza.position.x - starsTexture.get_width()/2, pizza.position.y + 40)
        var src = Rect2(Vector2(), starsTexture.get_size())
        var rect = Rect2(position, starsTexture.get_size())
        var rectRegion = Rect2(rect)
        src.size.x *= pizza.score/5
        rectRegion.size.x *= pizza.score/5

        draw_texture_rect(starsTexture, rect, false, Color(.1, .1, .1))
        draw_texture_rect_region(starsTexture, rectRegion, src)





func _get_configuration_warnings():
    if not Engine.is_editor_hint(): return

    var result = []

    if not has_node("scorer"): result.append("Missing 'scorer' node")
    if get_tree().get_nodes_in_group("dough").size() == 0: result.append("No dough in scene, nothing to score")
    if get_tree().get_nodes_in_group("order").size() == 0: result.append("No orders in scene, pizzas won't be scored")

    return result
