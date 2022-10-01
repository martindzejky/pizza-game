extends Node2D


func _process(delta):
    # animate the hand based on the timer
    var percentage = 1.0 - $timer.time_left / $timer.wait_time
    $hand.rotation = -PI/2 + percentage * PI*2
