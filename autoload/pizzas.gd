@tool
extends Node2D

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

    print("------------")
    print("Pizza scoring:")

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

        var score := 0.0
        if count <= 2:
            score = clamp(count / 2.0, 0.0, 1.0)
        else:
            score = clamp((4 - count) / 2.0, 0.0, 1.0)


        print("Ingredient: ", order.recipe[i], " count: ", count)
        print("Ingredient score: ", score)

        fulfilledIngredients += score
        previousIngredient = order.recipe[i]

    # TODO: extra ingredients are not counted

    var ingredientScore =  float(fulfilledIngredients) / ingredients

    print("Ingredients total score: ", ingredientScore)
    print("Ingredients: ", ingredients)
    print("Fulfilled ingredients: ", fulfilledIngredients)

    # DOUGH PROCESS and COOKING

    var dougScore = (pizza.getProgress() + pizza.getCookProgress()) / 2.0

    print("Dough score: ", dougScore)
    print("Dough progress: ", pizza.getProgress())
    print("Dough cook progress: ", pizza.getCookProgress())

    # INGREDIENTS COOKING

    var ingredientsScore = pizza.get_children().filter(func(node): return node.is_in_group("ingredient")).reduce(func(acc, node): return acc * node.getCookProgress(), 1.0)

    print("Ingredients cook score: ", ingredientsScore)

    # TOMATE BASE

    var hasBase = _pizzaHasTomatoBase(pizza)
    if hasBase:
        print("Pizza has tomato base")
    else:
        print("Pizza has no tomato base")

    # COMBINE

    var score = (ingredientScore + dougScore + ingredientsScore) / 3.0 * 5.0

    if not hasBase:
        score *= 0.7
        print("Pizza has no tomato base, score reduced by 30%")

    if pizza.isCookOvercooked():
        score *= 0.2
        print("Pizza is burnt, score reduced by 80%")

    print("Total score: ", score)
    print("------------")

    return score


func _pizzaIngredientCount(pizza: Node, name: String) -> int:
    return pizza.get_children().filter(func (node): return node.is_in_group(name)).size()

func _pizzaHasTomatoBase(pizza: Node) -> bool:
    return pizza.get_children().filter(func (node): return node.is_in_group("tomato-base")).size() > 0
