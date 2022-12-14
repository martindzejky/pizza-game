@tool
extends Pickable


# cooking in the oven
@export var scoringData: ScoringData
@export var cookProgress := 0.0


func _ready():
    if Engine.is_editor_hint(): return

    $sprite.rotation = randf() * PI * 2

    if randf() < 0.5:
        $sprite.flip_h = true
    if randf() < 0.5:
        $sprite.flip_v = true

func _process(delta):
    super(delta)

    # update saturation based on cook progress
    var color = 1

    if cookProgress <= scoringData.requiredCookingTime:
        color = lerp(1.0, 0.9, cookProgress / scoringData.requiredCookingTime)
    elif cookProgress <= scoringData.overcookedTime :
        var value = (cookProgress - scoringData.requiredCookingTime) / (scoringData.overcookedTime - scoringData.requiredCookingTime)
        var valueEased = 1-ease(1-value, scoringData.ingredientEasing)
        color = lerp(0.9, 0.3, valueEased)
    else:
        color = 0.2

    $sprite.self_modulate = Color(color, color, color, $sprite.self_modulate.a)


func _onClick() -> bool:
    if Hand.isEmpty():
        Hand.pick(self)
        return true

    elif Hand.isCarryingDoughTool():
        Effects.swing(Hand.getCarriedItem())
        Effects.sound("dough")
        crash()

        return true

    return false


func isRaw():
    return cookProgress < scoringData.rawTime

func isCookReady():
    return cookProgress >= scoringData.requiredCookingTime and cookProgress < scoringData.overcookedTime

func isCookOvercooked():
    return cookProgress >= scoringData.overcookedTime

func getCookProgress():
    var p = float(cookProgress) - scoringData.requiredCookingTime
    if p < 0: return 0.0

    p = p / (scoringData.overcookedTime - scoringData.requiredCookingTime)

    return clamp(1.0 - p, 0.0, 1.0)

func crash():
    # destroy this ingredient
    queue_free()

    # play the particles
    $particles.amount = randi_range(4, 8)
    $particles.lifetime = randf_range(0.5, 1.0)

    var node = $particles
    var position = $particles.global_position
    remove_child(node)
    Effects.particles(node, position)
