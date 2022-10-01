extends Pickable


const PROGRESS_READY = 4
const PROGRESS_DESTROYED = 5
@export var progress := 0


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                if isPicked:
                    Hand.drop()

                elif Hand.isEmpty():
                    Hand.pick(self)

                else:
                    pass
                    # TODO: interactions with other objects
