extends Sprite2D


# where to insert recipe images based on this order
@export var recipePath: NodePath
# recipe object for the preview UI
@export var recipeObj: PackedScene

const OPTIONS = ["mushroom", "corn", "olive", "rukola", "cheese", "salam"]

# Required ingredients for the recipe. If there is an ingredient multiple times, an extra amount is required.
var recipe: Array


func _ready():
    # enter transition

    var x = -20
    var newX = 20 + randf() * 10
    var y = -20 + randf() * 40
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

    return true
