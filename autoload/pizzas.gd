extends Node2D

func _ready():
    # hidden collection of submitted pizzas
    hide()


# Score pizza based on open orders. Use the best rating order.
# If there's no order, the score is 0. Scoring is 0 (worst) - 5 (best).
func score(pizza: Node):

    var openOrders = get_tree().get_nodes_in_group("order")

    if openOrders.size() == 0:
        # :'( no one to eat it...
        pizza.score = 0
        print("No orders, pizza scored 0")
        return

    var bestScore = 0
    var bestOrder = openOrders[0]

    for order in openOrders:
        var score = _scoreBasedOnOrder(pizza, order)
        if score > bestScore:
            bestScore = score
            bestOrder = order

    # accept best order
    bestOrder.accept(bestScore)
    pizza.score = bestScore

    print("Pizza scored: ", bestScore)


func _scoreBasedOnOrder(pizza: Node, order: Node) -> float:
    if not pizza: return 0.0
    if not order: return 0.0
    if not 'recipe' in order: return 0.0
    if order.recipe.size() == 0: return 0.0

    var ingredients = 0.0
    var fulfilledIngredients = 0.0

    var previousIngredient
    for i in range(order.recipe.size()):
        var count = _pizzaIngredientCount(pizza, order.recipe[i])

        # detect extra ingredients
        if previousIngredient == order.recipe[i]:
            fulfilledIngredients += 0.4 # BONUS!
            continue

        ingredients += 1

        if count <= 3:
            fulfilledIngredients += clamp(count / 3.0, 0.0, 1.0)
        else:
            fulfilledIngredients += clamp((6 - count) / 3.0, 0.0, 1.0)

    # TODO: extra ingredients are not counted

    var ingredientScore =  float(fulfilledIngredients) / ingredients

    if not pizza.isReady() and not pizza.isOverdone():
        # raw pizza dough, who would eat that
        return 0.0

    if not pizza.isCookReady() and not pizza.isCookOvercooked():
        # not cooked
        return 0.0

    var dougScore = (pizza.getProgress() + pizza.getCookProgress()) / 2.0

    return (ingredientScore + dougScore) / 2.0 * 5.0


func _pizzaIngredientCount(pizza: Node, name: String) -> int:
    return pizza.get_children().filter(func (node): return node.is_in_group(name)).size()
