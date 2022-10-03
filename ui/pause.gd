extends CanvasLayer

var wasMouseHidden := false

func _input(event: InputEvent):

    # only care about ESC (on release)
    if not event is InputEventKey: return
    if event.keycode != KEY_ESCAPE: return
    if not event.is_pressed(): return

    get_tree().paused = not get_tree().paused
    $root.visible = get_tree().paused

    # reveal mouse if it was hidden by the Hand
    if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        wasMouseHidden = true
    else:
        if wasMouseHidden:
            Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
            wasMouseHidden = false
