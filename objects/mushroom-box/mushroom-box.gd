extends Node2D


@export var ingredient: PackedScene


func _onClick() -> bool:

    # spawn a new ingredient that is picked
    var ing = ingredient.instantiate()

    # only allow picking the ingredient if the hand
    # is empty or already has the same ingredient
    if not Hand.isEmpty():
        for group in ing.get_groups():
            if not Hand.isCarryingIngredient(group):
                return false


    get_tree().call_group("table", "add_child", ing)
    Hand.pick(ing)

    Effects.sound("pickup")

    return true
