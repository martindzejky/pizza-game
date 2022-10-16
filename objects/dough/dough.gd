@tool
extends Pickable


# from raw to pizza dough
const PROGRESS_READY = 6
# TODO: PROGRESS_WELL_MADE for bonus points
const PROGRESS_OVERDONE = 13
@export var progress := 0

# cooking in the oven
@export var scoringData: ScoringData
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
    if progress >= $sprite.hframes and not Engine.is_editor_hint():
        queue_free()
        return

    $sprite.frame = progress

    # update saturation based on cook progress
    var color = 1.0

    if cookProgress <= scoringData.requiredCookingTime:
        color = lerp(1.0, 0.9, cookProgress / scoringData.requiredCookingTime)
    elif cookProgress <= scoringData.overcookedTime :
        var value = (cookProgress - scoringData.requiredCookingTime) / (scoringData.overcookedTime - scoringData.requiredCookingTime)
        var valueEased = 1-ease(1-value, scoringData.cookingEasing)
        color = lerp(0.9, 0.3, valueEased)
    else:
        color = 0.2

    $sprite.self_modulate = Color(color, color, color, 1)

    # update particles state
    if not Engine.is_editor_hint():
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
    Effects.swing(Hand.getCarriedItem())
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
    return cookProgress < scoringData.rawTime

func isReady():
    return progress >= PROGRESS_READY and progress < PROGRESS_OVERDONE

func isOverdone():
    return progress >= PROGRESS_OVERDONE

func isCookReady():
    return cookProgress >= scoringData.requiredCookingTime and cookProgress < scoringData.overcookedTime

func isCookOvercooked():
    return cookProgress >= scoringData.overcookedTime

func getProgress():
    var p = float(progress) - PROGRESS_READY
    if p < 0: return 0.0

    p = p / (PROGRESS_OVERDONE - PROGRESS_READY)

    return clamp(1.0 - p, 0.0, 1.0)

func getCookProgress():
    var p = float(cookProgress) - scoringData.requiredCookingTime
    if p < 0: return 0.0

    p = p / (scoringData.overcookedTime  - scoringData.requiredCookingTime)

    return clamp(1.0 - p, 0.0, 1.0)


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

    Effects.wiggle(self)

    return true

func insertTomatoBase() -> bool:
    if not Hand.isCarryingSpoon(): return false
    if not Hand.getCarriedItem().isFull: return false
    if not isReady(): return false

    Hand.getCarriedItem().empty()

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

    Effects.wiggle(self)
    Effects.swing(Hand.getCarriedItem())

    return true
