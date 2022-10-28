extends AudioStreamPlayer

# Ensures that the music is synced with the level.
# There are 2 timers:
# "timer" counts the 3 minutes, this is used for syncing the music
# "beat" triggers regularly to do the actual syncing
# NOTE: I don't think this was actually necessary to do in Godot, but I did it
# anyway to test how it would work :shrug:

func _on_beat_timeout():
    var time: float = $timer.wait_time - $timer.time_left
    get_tree().call_group("music", "seek", time)
