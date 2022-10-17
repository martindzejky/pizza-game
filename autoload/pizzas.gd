@tool
extends Node2D

# because this is an autoload, hard-code the path to the data resource
var scoringData: ScoringData = preload("res://scoring/scoring-data.tres")

func _ready():
    # hidden collection of submitted pizzas
    if not Engine.is_editor_hint(): hide()


# Score pizza based on open orders. Use the best rating order.
# If there's no order, the score is 0. Scoring is 0 (worst) - 5 (best).
func score(pizza: Node, testMode = false) -> float:

    if pizza.isRaw():
        # who would eat that...
        if not testMode: pizza.score = 0.0
        print("Raw pizza!")
        return 0.0

    var openOrders = get_tree().get_nodes_in_group("order")

    if openOrders.size() == 0:
        # :'( no one to eat it...
        if not testMode: pizza.score = 0.0
        print("No orders, pizza scored 0")
        return 0.0

    var bestScore = 0.0
    var bestOrder = openOrders[0]

    for order in openOrders:
        var score = _scoreBasedOnOrder(pizza, order)
        if score > bestScore:
            bestScore = score
            bestOrder = order

    # accept best order
    if not testMode:
        pizza.score = bestScore
        bestOrder.accept(pizza)

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

    print("Ingredients:")
    var ingredientScore = 1.0

    var pizzaIngredients = _pizzaGetIngredients(pizza)
    var recipeIngredients = order.recipe.reduce(_reduceOrderIngredients, {})

    # first check the recipe ingredients
    for recipeIngredient in recipeIngredients:
        var onPizza = _pizzaIngredientCount(pizza, recipeIngredient)

        if recipeIngredients[recipeIngredient] > 1:
            # extra required
            var ingScore = 0.0

            if onPizza >= scoringData.requiredExtraIngredients:
                ingScore = 1.0
            elif onPizza <= 0:
                ingScore = 0.0
            else:
                var value = 1.0 * onPizza / scoringData.requiredExtraIngredients
                ingScore = ease(value, scoringData.requiredExtraIngredientsEasing)

            print("  ", recipeIngredient, " (extra) score: ", ingScore)
            ingredientScore *= ingScore
            print("= ingredient score: ", ingredientScore)

        else:
            # normal required
            var ingScore = 0.0

            if onPizza >= scoringData.requiredIngredients:
                ingScore = 1.0
            elif onPizza <= 0:
                ingScore = 0.0
            else:
                var value = 1.0 * onPizza / scoringData.requiredIngredients
                ingScore = ease(value, scoringData.requiredIngredientsEasing)

            var weight = 1.0 / recipeIngredients.size()
            var weightedIngScore = 1.0 - weight + ingScore * weight

            print("  ", recipeIngredient, " score: ", ingScore)
            ingredientScore *= weightedIngScore
            print("= ingredient score: ", ingredientScore)

    # now check ingredients that weren't requested by the recipe
    for pizzaIngredient in pizzaIngredients:
        # ignore tomato base
        if pizzaIngredient.is_in_group("tomato-base"): continue

        var groups = pizzaIngredient.get_groups().filter(func (g): return g in recipeIngredients)
        if groups.size() == 0:
            print("  unrequested: ", pizzaIngredient)
            ingredientScore *= 1.0 - scoringData.unrequestedIngredientPenalty

    print("Ingredients total score: ", ingredientScore)
    score *= ingredientScore
    print("Score after ingredients: ", score)

    # DOUGH PROCESS and COOKING

    var dougScore = pizza.getProgress()
    var doughCookScore = pizza.getCookProgress()

    print("Dough score: ", dougScore)
    print("Dough cook score: ", doughCookScore)

    score *= ease(dougScore, scoringData.doughEasing)
    print("Score after dough: ", score)
    score *= ease(doughCookScore, scoringData.cookingEasing)
    print("Score after dough cook: ", score)

    # INGREDIENTS COOKING

    print("Ingredients cooking:")
    var ingredientCookingScore = 1.0

    #_pizzaGetIngredients(pizza).reduce(func(acc, node): return acc * node.getCookProgress(), 1.0)
    for pizzaIngredient in pizzaIngredients:
        var ingCookScore = pizzaIngredient.getCookProgress()
        print("  ", pizzaIngredient.name, " cooking score: ", ingCookScore)
        ingredientCookingScore *= ease(ingCookScore, scoringData.ingredientEasing)
        print("= ingredient cooking score: ", ingredientCookingScore)

    print("Ingredients cooking total score: ", ingredientCookingScore)
    var ingredientCookingWeightedScore = 1.0 - scoringData.ingredientCookingScoreWeight + scoringData.ingredientCookingScoreWeight * ingredientCookingScore
    score *= ingredientCookingWeightedScore
    print("Score after ingredients cook: ", score)

    # TOMATO BASE

    var hasBase = _pizzaHasTomatoBase(pizza)
    if hasBase:
        print("Pizza has tomato base")
        # no changes to the score
    else:
        print("Pizza has no tomato base")
        score *= 1.0 - scoringData.noTomatoBasePenalty
        print("Score after tomato base reduction: ", score)

    # FINAL MODIFICATIONS

    if pizza.isCookOvercooked():
        score *= 1.0 - scoringData.overcookedPenalty
        print("Pizza is burnt, score reduced to: ", score)

    for ingredient in _pizzaGetIngredients(pizza):
        if ingredient.isCookOvercooked():
            score *= 1.0 - scoringData.overcookedIngredientPenalty
            print("Ingredient is burnt, score reduced to: ", score)

    # TOTAL

    print("Total score: ", score)
    print("------------")

    return score

func _pizzaGetIngredients(pizza: Node) -> Array:
    return pizza.get_children().filter(func(node): return node.is_in_group("ingredient"))

func _pizzaIngredientCount(pizza: Node, name: String) -> int:
    return pizza.get_children().filter(func (node): return node.is_in_group(name)).size()

func _pizzaHasTomatoBase(pizza: Node) -> bool:
    return pizza.get_children().filter(func (node): return node.is_in_group("tomato-base")).size() > 0

func _reduceOrderIngredients(acc, ingredient):
    if ingredient in acc:
        acc[ingredient] += 1
    else:
        acc[ingredient] = 1
    return acc
