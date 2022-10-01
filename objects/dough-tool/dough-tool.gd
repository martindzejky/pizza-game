extends Pickable


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                viewport.set_input_as_handled()

                if isPicked:
                    useOrDrop()

                elif Hand.isEmpty():
                    Hand.pick(self)

func useOrDrop() -> void:
    var overlappingAreas = $useArea.get_overlapping_areas()

    # filter self
    overlappingAreas = overlappingAreas.filter(func(area): return area.get_parent() != self)

    if overlappingAreas.size() <= 0:
        Hand.drop()
        return

    for area in overlappingAreas:
        var obj = area.get_parent()

        # ignore other tools
        if obj.is_in_group("tool"):
            continue

        if obj.is_in_group("dough"):
            if obj.has_method("onHitByDoughTool"):
                obj.onHitByDoughTool()
            else:
                print("Missing onHitByDoughTool method in ", obj)

            return
