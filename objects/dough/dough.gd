extends Pickable


# from raw to pizza dough
const PROGRESS_READY = 4
# TODO: PROGRESS_WELL_MADE for bonus points
const PROGRESS_OVERDONE = 5
@export var progress := 0

# cooking in the oven
const COOK_PROGRESS_RAW = 1.0
const COOK_PROGRESS_READY = 8.0
# TODO: COOK_PROGRESS_WELL_MADE for bonus points
const COOK_PROGRESS_OVERCOOKED = 10.0
@export var cookProgress := 0.0

# damage from hitting cooked dough
const MAX_DAMAGE = 3
@export var damage := 0



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
        color = lerp(1.0, 0.7, cookProgress / COOK_PROGRESS_READY)
    elif cookProgress <= COOK_PROGRESS_OVERCOOKED:
        color = lerp(0.7, 0.3, (cookProgress - COOK_PROGRESS_READY) / (COOK_PROGRESS_OVERCOOKED - COOK_PROGRESS_READY))
    else:
        color = 0.3

    $sprite.self_modulate = Color(color, color, color, 1)


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                if Hand.isEmpty():
                    Hand.pick(self)
                    viewport.set_input_as_handled()

                elif Hand.isCarryingDoughTool():
                    onHitByDoughTool()
                    viewport.set_input_as_handled()

                elif Hand.isCarryingIngredient():
                    if insertIngredient():
                        viewport.set_input_as_handled()


func onHitByDoughTool():
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


func insertIngredient() -> bool:
    var ingredient = Hand.drop()
    if not ingredient: return false

    var previousTransform = ingredient.get_global_transform()

    if ingredient.get_parent():
        ingredient.get_parent().remove_child(ingredient)

    add_child(ingredient)
    ingredient.set_global_transform(previousTransform)

    # disable interactive areas, the ingredient is now part of the dough
    ingredient.get_node("clickArea").queue_free()
    ingredient.get_node("useArea").queue_free()

    return true
