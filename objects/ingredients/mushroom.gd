extends Pickable


# cooking in the oven
const COOK_PROGRESS_RAW = 1.0
const COOK_PROGRESS_READY = 8.0
# TODO: COOK_PROGRESS_WELL_MADE for bonus points
const COOK_PROGRESS_OVERCOOKED = 10.0
@export var cookProgress := 0.0


func _ready():
    $sprite.rotation = randf() * PI * 2

    if randf() < 0.5:
        $sprite.flip_h = true
    if randf() < 0.5:
        $sprite.flip_v = true

func _process(delta):
    super(delta)

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
                    viewport.set_input_as_handled()

                    # TODO: particles
                    queue_free()


func isRaw():
    return cookProgress < COOK_PROGRESS_RAW

func isCookReady():
    return cookProgress >= COOK_PROGRESS_READY and cookProgress < COOK_PROGRESS_OVERCOOKED

func isCookOvercooked():
    return cookProgress >= COOK_PROGRESS_OVERCOOKED
