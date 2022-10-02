extends CanvasLayer

func _input(event: InputEvent):

    # only care about ESC (on release)
    if not event is InputEventKey: return
    if event.keycode != KEY_ESCAPE: return
    if not event.is_pressed(): return

    get_tree().paused = not get_tree().paused
    $root.visible = get_tree().paused
