extends CanvasLayer


func _ready():
    get_tree().paused = true

func _on_gui_input(event: InputEvent):

    # only care about left mouse clicks (on release)
    if not event is InputEventMouseButton: return
    if event.button_index != MOUSE_BUTTON_LEFT: return
    if not event.is_pressed(): return

    nextSlide()


func nextSlide():
    var slides = $root.get_children()
    var current = slides[0]

    for slide in slides:
        if slide.visible:
            current = slide
            break

    if current.get_index() >= slides.size() - 1:
        dismiss()
        return

    current.visible = false
    slides[current.get_index() + 1].visible = true


func dismiss():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/level.tscn")
