@tool
extends Node2D

# because this is an autoload, hard-code the path to the data resource
var scoringData: ScoringData = preload("res://scoring/scoring-data.tres")

func _ready():
    # hidden collection of submitted pizzas
    if not Engine.is_editor_hint(): hide()


# Score pizza based on open orders. Use the best rating order.
# If there's no order, the score is 0. Scoring is 0 (worst) - 5 (best).
func score(pizza: Node, testMode = false) -> int:

    if pizza.isRaw():
        # who would eat that...
        pizza.score = 0
        print("Raw pizza!")
        return 0

    var openOrders = get_tree().get_nodes_in_group("order")

    if openOrders.size() == 0:
        # :'( no one to eat it...
        pizza.score = 0
        print("No orders, pizza scored 0")
        return 0

    var bestScore = 0
    var bestOrder = openOrders[0]

    for order in openOrders:
        var score = _scoreBasedOnOrder(pizza, order)
        if score > bestScore:
            bestScore = score
            bestOrder = order

    # accept best order
    if not testMode:
        bestOrder.accept(bestScore)
        pizza.score = bestScore

    print("Pizza scored: ", bestScore)
    return bestScore


func _scoreBasedOnOrder(pizza: Node, order: Node) -> float:
    if not pizza: return 0.0
    if not order: return 0.0
    if not 'recipe' in order: return 0.0
    if order.recipe.size() == 0: return 0.0

    var score = 5.0

    print("------------")
    print("Pizza scoring:")
    print("Starting score: ", score)

    # INGREDIENTS

    var ingredients = 0.0
    var fulfilledIngredients = 0.0

    var previousIngredient
    for i in range(order.recipe.size()):
        var count = _pizzaIngredientCount(pizza, order.recipe[i])

        # detect extra ingredients
        if previousIngredient == order.recipe[i] and count > 3:
            print("Extra ingredient fulfilled: ", order.recipe[i])
            fulfilledIngredients += 0.4 # BONUS!
            continue

        ingredients += 1

        # TODO: tweakable
        var ingredientScore := 0.0
        if count <= 2:
            ingredientScore = clamp(count / 2.0, 0.0, 1.0)
        else:
            ingredientScore = clamp((4 - count) / 2.0, 0.0, 1.0)


        print("Ingredient: ", order.recipe[i], " count: ", count)
        print("Ingredient score: ", ingredientScore)

        fulfilledIngredients += ingredientScore
        previousIngredient = order.recipe[i]

    # TODO: unrequested ingredients are not counted yet

    var ingredientScore =  float(fulfilledIngredients) / ingredients

    print("Ingredients total score: ", ingredientScore)
    score *= ingredientScore # TODO: easing
    print("Score after ingredients: ", score)

    # DOUGH PROCESS and COOKING

    var dougScore = pizza.getProgress()
    var doughCookScore = pizza.getCookProgress()

    print("Dough score: ", dougScore)
    print("Dough cook score: ", doughCookScore)

    score *= dougScore # TODO: easing
    print("Score after dough: ", score)
    score *= doughCookScore # TODO: easing
    print("Score after dough cook: ", score)

    # INGREDIENTS COOKING

    var ingredientsScore = pizza.get_children().filter(func(node): return node.is_in_group("ingredient")).reduce(func(acc, node): return acc * node.getCookProgress(), 1.0)

    print("Ingredients cook score: ", ingredientsScore)
    score *= ingredientsScore # TODO: easing
    print("Score after ingredients cook: ", score)

    # TOMATO BASE

    var hasBase = _pizzaHasTomatoBase(pizza)
    if hasBase:
        print("Pizza has tomato base")
        # no changes to the score
    else:
        print("Pizza has no tomato base")
        score *= 0.5 # TODO: tweakable
        print("Score after tomato base reduction: ", score)

    # FINAL MODIFICATIONS

    if pizza.isCookOvercooked():
        score *= 0.2
        print("Pizza is burnt, score reduced by 80% to: ", score)

    for ingredient in pizza.get_children().filter(func(node): return node.is_in_group("ingredient")):
        if ingredient.isCookOvercooked():
            score *= 0.8
            print("Ingredient is burnt, score reduced by 20% to: ", score)

    # TOTAL

    print("Total score: ", score)
    print("------------")

    return score


func _pizzaIngredientCount(pizza: Node, name: String) -> int:
    return pizza.get_children().filter(func (node): return node.is_in_group(name)).size()

func _pizzaHasTomatoBase(pizza: Node) -> bool:
    return pizza.get_children().filter(func (node): return node.is_in_group("tomato-base")).size() > 0
