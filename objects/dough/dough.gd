extends Pickable


# from raw to pizza dough
const PROGRESS_READY = 6
# TODO: PROGRESS_WELL_MADE for bonus points
const PROGRESS_OVERDONE = 13
@export var progress := 0

# cooking in the oven
const COOK_PROGRESS_RAW = 1.0
const COOK_PROGRESS_READY = 5.0
# TODO: COOK_PROGRESS_WELL_MADE for bonus points
const COOK_PROGRESS_OVERCOOKED = 12.0
@export var cookProgress := 0.0

# damage from hitting cooked dough
const MAX_DAMAGE = 3
@export var damage := 0


# tomato base
@export var tomatoBaseObj: PackedScene


# final score, 0-5
@export var score := 0.0



func _process(delta):
    super(delta)

    # update sprite frame based on progress
    if progress >= $sprite.hframes:
        queue_free()
        return

    $sprite.frame = progress

    # update saturation based on cook progress
    var color = 1

    if cookProgress <= COOK_PROGRESS_READY:
        color = lerp(1.0, 0.95, cookProgress / COOK_PROGRESS_READY)
    elif cookProgress <= COOK_PROGRESS_OVERCOOKED:
        color = lerp(0.95, 0.3, (cookProgress - COOK_PROGRESS_READY) / (COOK_PROGRESS_OVERCOOKED - COOK_PROGRESS_READY))
    else:
        color = 0.2

    $sprite.self_modulate = Color(color, color, color, 1)

    # update particles state
    $particlesWarm.emitting = isCookReady()
    $particlesOvercooked.emitting = isCookOvercooked()


func _onClick() -> bool:
    # special case, ignore when inside a closed oven
    if not visible:
        return false

    if Hand.isEmpty():
        Hand.pick(self)
        Effects.sound("pickup")

        # unsquash from oven
        scale.y = 1.0

        return true

    if Hand.isCarryingDoughTool():
        onHitByDoughTool()
        return true

    if Hand.isCarryingIngredient():
        if insertIngredient():
            Effects.sound("ingredient")
            return true

    if Hand.isCarryingSpoon():
        if insertTomatoBase():
            Effects.sound("ingredient")
            return true

    return false


func onHitByDoughTool():
    Effects.wiggle(self)
    Effects.sound("dough")

    # remove all ingredients
    for child in get_children():
        if child.is_in_group("ingredient"):
            child.queue_free()

    if isRaw():
        progress += 1
    else:
        damage += 1

        if damage >= MAX_DAMAGE:
            # TODO: spawn pieces of dough
            queue_free()

func isRaw():
    return cookProgress < COOK_PROGRESS_RAW

func isReady():
    return progress >= PROGRESS_READY and progress < PROGRESS_OVERDONE

func isOverdone():
    return progress >= PROGRESS_OVERDONE

func isCookReady():
    return cookProgress >= COOK_PROGRESS_READY and cookProgress < COOK_PROGRESS_OVERCOOKED

func isCookOvercooked():
    return cookProgress >= COOK_PROGRESS_OVERCOOKED

func getProgress():
    var p = float(progress) - PROGRESS_READY
    if p < 0: return 0.0

    p = p / (PROGRESS_OVERDONE - PROGRESS_READY)

    return clamp(1.0 - p / 2, 0.0, 1.0)

func getCookProgress():
    var p = float(cookProgress) - COOK_PROGRESS_READY
    if p < 0: return 0.0

    p = p / (COOK_PROGRESS_OVERCOOKED - COOK_PROGRESS_READY)

    return clamp(1.0 - p / 2, 0.0, 1.0)


func insertIngredient() -> bool:
    var ingredient = Hand.drop()
    if not ingredient: return false

    var previousTransform = ingredient.get_global_transform()

    if ingredient.get_parent():
        ingredient.get_parent().remove_child(ingredient)

    add_child(ingredient)
    ingredient.set_global_transform(previousTransform)

    # disable interactive areas, the ingredient is now part of the dough
    ingredient.remove_from_group("click")
    ingredient.get_node("clickArea").queue_free()

    # fade out a little
    var color = ingredient.get_node("sprite").self_modulate
    ingredient.get_node("sprite").self_modulate = Color(color.r, color.g, color.b, 0.7)

    return true

func insertTomatoBase() -> bool:
    if not Hand.carrying.isFull: return false
    if not isReady(): return false

    Hand.carrying.empty()

    var tomatoBase = tomatoBaseObj.instantiate()
    tomatoBase.position.y = 2 + randi() % 4
    tomatoBase.position.x = -2 + randi() % 4
    add_child(tomatoBase)

    # random rotation
    tomatoBase.get_node("sprite").rotation = randf() * PI * 2

    # disable interactive areas, the ingredient is now part of the dough
    tomatoBase.remove_from_group("click")
    tomatoBase.get_node("clickArea").queue_free()

    # fade out a little
    var color = tomatoBase.get_node("sprite").self_modulate
    tomatoBase.get_node("sprite").self_modulate = Color(color.r, color.g, color.b, 0.7)

    return true
