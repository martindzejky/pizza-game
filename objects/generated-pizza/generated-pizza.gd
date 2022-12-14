extends Node2D

# When instantiated, generates a random pizza with ingredients
# and random cooking progress.

@export var tomatoBase: PackedScene
@export var ingredients: Array[PackedScene]


func _ready():
    # dough
    $dough.progress = randi_range(6, 12)
    $dough.cookProgress = randf_range(2.0, 14.0)

    # tomato base
    if randf() < 0.9:
        var tomato = tomatoBase.instantiate()
        tomato.position.y = 2 + randi() % 4
        tomato.position.x = -2 + randi() % 4
        tomato.get_node("sprite").rotation = randf() * PI * 2
        tomato.get_node("sprite").self_modulate.a = 0.7
        tomato.cookProgress = $dough.cookProgress + randf_range(-2.0, 2.0)
        $dough.add_child(tomato)

    # ingredients
    for i in range(randi_range(3, 8)):
        var ingredient = ingredients[randi_range(0, ingredients.size() - 1)].instantiate()
        ingredient.position.x = randf_range(-17, 17)
        ingredient.position.y = randf_range(-17, 17)
        ingredient.get_node("sprite").rotation = randf() * PI * 2
        ingredient.get_node("sprite").self_modulate.a = 0.7
        ingredient.cookProgress = $dough.cookProgress + randf_range(-2.0, 2.0)
        $dough.add_child(ingredient)
