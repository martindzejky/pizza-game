extends Pickable


# from raw to pizza dough
const PROGRESS_READY = 4
const PROGRESS_DESTROYED = 5
@export var progress := 0

# cooking in the oven
const COOK_PROGRESS_READY = 8.0
const COOK_PROGRESS_DESTROYED = 10.0
@export var cookProgress := 0.0



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
    elif cookProgress <= COOK_PROGRESS_DESTROYED:
        color = lerp(0.7, 0.3, (cookProgress - COOK_PROGRESS_READY) / (COOK_PROGRESS_DESTROYED - COOK_PROGRESS_READY))
    else:
        color = 0.3

    $sprite.modulate = Color(color, color, color, 1)


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                if isPicked:
                    useOrDrop()

                elif Hand.isEmpty():
                    Hand.pick(self)


func onHitByDoughTool():
    progress += 1

func isReady():
    return progress >= PROGRESS_READY

func isDestroyed():
    return progress >= PROGRESS_DESTROYED

func isCookReady():
    return cookProgress >= COOK_PROGRESS_READY

func isCookDestroyed():
    return cookProgress >= COOK_PROGRESS_DESTROYED

func useOrDrop() -> void:
    var overlappingAreas = $useArea.get_overlapping_areas()

    # filter self
    overlappingAreas = overlappingAreas.filter(func(area): return area.get_parent() != self)

    if overlappingAreas.size() <= 0:
        Hand.drop()
        return

    for area in overlappingAreas:
        var obj = area.get_parent()

        if obj.is_in_group("oven"):
            # TODO
            return
