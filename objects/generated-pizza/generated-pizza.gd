extends Node2D

# When instantiated, generates a random pizza with ingredients.
# Moves to the right and destroys itself when it reaches the end of the screen.

@export var speed: int

@export var tomatoBase: PackedScene
@export var ingredients: Array[PackedScene]


func _ready():
    # dough
    #$dough.rotation = randf_range(-PI/3, PI/3)
    $dough.frame = randi_range($dough.frame, $dough.hframes - 4)

    # tomato base
    if randf() < 0.9:
        var tomato = tomatoBase.instantiate()
        tomato.position.y = 2 + randi() % 4
        tomato.position.x = -2 + randi() % 4
        tomato.get_node("sprite").rotation = randf() * PI * 2
        tomato.get_node("sprite").self_modulate.a = 0.7
        add_child(tomato)

    # ingredients
    for i in range(randi_range(3, 8)):
        var ingredient = ingredients[randi_range(0, ingredients.size() - 1)].instantiate()
        ingredient.position.x = randf_range(-17, 17)
        ingredient.position.y = randf_range(-17, 17)
        ingredient.get_node("sprite").rotation = randf() * PI * 2
        ingredient.get_node("sprite").self_modulate.a = 0.7
        add_child(ingredient)


func _process(delta):
    global_position.x += speed * delta
    if global_position.x > 500:
        queue_free()