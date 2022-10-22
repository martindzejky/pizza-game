extends Node2D

# Handles transitions between scenes

var targetScene: String = ''


# Transition to a new scene
func transitionTo(scene: String, text := ''):
    if $animation.is_playing(): return

    if text != '':
        $layer/cover/center/text.text = text
        $layer/cover/center/text.visible = true
    else:
        $layer/cover/center/text.visible = false

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
