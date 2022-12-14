extends Sprite2D


# preview panel to animate
@export var panelPath: NodePath
# where to insert recipe images based on this order
@export var recipePath: NodePath
# recipe object for the preview UI
@export var recipeObj: PackedScene

# when succeded, this is the associated pizza
@export var associatedPizza: Node
@export var status: String # "success" or "fail"
var animateOutTween: Tween

const OPTIONS = ["mushroom", "corn", "olive", "rukola", "cheese", "salam"]

# Required ingredients for the recipe. If there is an ingredient multiple times, an extra amount is required.
@export var recipe: Array[String]

# tweening the popup
var tween: Tween
var showPreview = false


func _ready():
    # enter transition

    Effects.sound("order")

    var tween := create_tween()
    tween.tween_property(self, "position:y", -60, 0.6).as_relative().set_ease(Tween.EASE_OUT)

    # move all other orders up
    for child in get_parent().get_children():
        if child != self and child.is_in_group("order"):
            child.moveUp()

    # generate recipe
    recipe = []

    # TODO: based on difficulty (open orders, remaining time), generate a recipe with more or less ingredients
    var amount = 2 + randi() % 3

    while amount > 0:
        var ingredient = OPTIONS[randi() % OPTIONS.size()]
        recipe.append(ingredient)
        amount -= 1

    recipe.sort()

    # set up the large preview UI
    var recipeNode = get_node(recipePath)
    for child in recipeNode.get_children():
        child.queue_free()

    var previousIngredient
    var previousIngredientNode

    for i in range(recipe.size()):
        # detect extra ingredients
        if previousIngredient == recipe[i]:
            previousIngredientNode.get_node("extra").show()

            previousIngredient = recipe[i]
            continue

        previousIngredientNode = recipeObj.instantiate()

        previousIngredientNode.get_node("sprite").texture = load("res://sprites/" + recipe[i] + ".png")
        previousIngredientNode.get_node("label").text = recipe[i].capitalize()

        recipeNode.add_child(previousIngredientNode)
        previousIngredient = recipe[i]


func _onClick() -> bool:
    # open the large preview
    Effects.sound("preview")
    togglePreview()
    return true


func togglePreview():
    showPreview = not showPreview

    if tween: tween.kill()
    tween = create_tween()

    var panel = get_node(panelPath)

    if showPreview:
        tween.tween_property(panel, "visible", true, 0)
        tween.tween_property(panel, "position:y", 0, 0.4).from_current().set_ease(Tween.EASE_OUT)
    else:
        tween.tween_property(panel, "position:y", 270, 0.4).from_current().set_ease(Tween.EASE_IN)
        tween.tween_property(panel, "visible", false, 0)

func _on_panel_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                _onClick()


func moveUp() -> void:
    # move up when a new order arrives, unless we are already done/failed
    if not is_in_group("order"): return

    var count = get_parent().get_child_count()
    var delay = (count - get_index()) * 0.15 + 0.07

    var time = 0.4
    var tween := create_tween()
    tween.tween_property(self, "position:y", -30, time).as_relative().set_delay(delay)



# Called by Pizzas when a pizza fulfilling this order is delivered.
func accept(pizza: Node) -> void:
    $clock.hide()
    $check.show()
    if showPreview: togglePreview()
    Effects.sound("orderDone")

    $stars.show()
    $stars.region_rect.size.x = floor(pizza.score * 16)

    associatedPizza = pizza
    status = "success"

    animateOut()

# Called by the fail timer
func fail() -> void:
    $clock.hide()
    $cross.show()
    if showPreview: togglePreview()
    Effects.sound("orderFail")

    associatedPizza = null
    status = "fail"

    animateOut()

func animateOut() -> void:
    # move to the end of the parent to be rendered on top of other orders
    get_parent().move_child(self, -1)

    # remove from group 'order' so it can't be accepted anymore
    # and from 'click' so it can't be clicked anymore
    remove_from_group("order")
    remove_from_group("click")

    # this is so that we can track orders which still need to be handled at the end of the level
    add_to_group("order-animating")

    $failTimer.stop()

    # leave transition
    animateOutTween = create_tween()
    animateOutTween.tween_property(self, "position:x", 60, 0.4).as_relative().set_ease(Tween.EASE_IN).set_delay(3.0)
    animateOutTween.tween_callback(finalizeOrder)

func finalizeOrder() -> void:

    # add the 'click' group again so it can be clicked in the gallery
    add_to_group("click")
    remove_from_group("order-animating")

    $stars.hide()
    position = Vector2()

    # cancel animation
    if animateOutTween: animateOutTween.kill()

    if status == "success":
        # move to the associated pizza
        get_parent().remove_child(self)
        associatedPizza.add_child(self)
        add_to_group("order-success")
        return

    if status == "fail":
        # track failed orders
        get_parent().remove_child(self)
        Orders.add_child(self)
        add_to_group("order-fail")
        return

    # this should never happen but "just in case..."
    queue_free()
    return
