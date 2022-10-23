extends Node2D

# Handles transitions between scenes

var targetScene: String = ''


func _ready():
    $layer.hide()
    $layer/cover.modulate.a = 0
    $layer/cover/center/container/text.visible = false


# Transition to a new scene
func transitionTo(scene: String, text := ''):
    if $animation.is_playing(): return

    if text != '':
        $layer/cover/center/container/text.text = text
        $layer/cover/center/container/text.visible = true
    else:
        $layer/cover/center/container/text.visible = false

    targetScene = scene
    $animation.play("transition")



# Called by the animation
func changeScene():
    if targetScene == '':
        push_warning("No target scene set")
        return

    get_tree().change_scene_to_file(targetScene)
    get_tree().paused = true

# Called by the animation
func unpause():
    get_tree().paused = false
