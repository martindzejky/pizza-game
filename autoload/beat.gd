extends Node

# Emits a signal every 500ms with the beat of the main music

signal beat
signal second
signal nineSeconds
signal tenSeconds

var beatAcc: float = 0
var secondAcc: int = 0
var tenSecondsAcc: int = 0

func _process(delta):
    beatAcc += delta

    if beatAcc >= 0.5:
        beatAcc -= 0.5
        secondAcc += 1
        emit_signal("beat")

    if secondAcc >= 2:
        secondAcc -= 2
        tenSecondsAcc += 1
        emit_signal("second")
        print("second")

        # can be used for ramp-up effects
        if tenSecondsAcc == 9:
            emit_signal("nineSeconds")
            print("nine seconds")

    if tenSecondsAcc >= 10:
        tenSecondsAcc -= 10
        emit_signal("tenSeconds")
        print("ten seconds")
