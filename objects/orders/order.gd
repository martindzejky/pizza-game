extends Sprite2D


# preview panel to animate
@export var panelPath: NodePath
# where to insert recipe images based on this order
@export var recipePath: NodePath
# recipe object for the preview UI
@export var recipeObj: PackedScene

const OPTIONS = ["mushroom", "corn", "olive", "rukola", "cheese", "salam"]

# Required ingredients for the recipe. If there is an ingredient multiple times, an extra amount is required.
var recipe: Array

# tweening
var tween: Tween
var showPreview = false


func _ready():
    # enter transition

    Effects.sound("order")

    var x = -20
    var newX = 20 + randf() * 30
    var y = -70 + randf() * 140
    var time = 0.2 + randf() * 0.4

    var tween := create_tween()
    tween.tween_property(self, "position", Vector2(newX, y), time).from(Vector2(x, y)).set_ease(Tween.EASE_OUT)

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

    showPreview = not showPreview

    if tween: tween.kill()
    tween = create_tween()

    var panel = get_node(panelPath)

    if showPreview:
        tween.tween_property(panel, "visible", true, 0)
        tween.tween_property(panel, "position:y", 66, 0.4).from_current().set_ease(Tween.EASE_OUT)
    else:
        tween.tween_property(panel, "position:y", 300, 0.4).from_current().set_ease(Tween.EASE_IN)
        tween.tween_property(panel, "visible", false, 0)

    return true

func _on_panel_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                _onClick()


# Called by Pizzas when a pizza fulfilling this order is delivered.
func accept(score: float) -> void:
    $check.show()
    Effects.sound("orderDone")

    $stars.show()
    $stars.region_rect.size.x = floor(score * 16)

    removeOrder()

# Called by the fail timer
func fail() -> void:
    $cross.show()
    Effects.sound("orderFail")
    removeOrder()

func removeOrder() -> void:
    # move to the end of the parent to be rendered on top of other orders
    get_parent().move_child(self, -1)

    # remove from group 'order' so it can't be accepted anymore
    # and from 'click' so it can't be clicked anymore
    remove_from_group("order")
    remove_from_group("click")

    $failTimer.stop()

    # leave transition

    var tween := create_tween()
    tween.tween_property(self, "position:x", -100, 0.5).as_relative().set_ease(Tween.EASE_OUT).set_delay(3.0)
    tween.tween_callback(queue_free)
