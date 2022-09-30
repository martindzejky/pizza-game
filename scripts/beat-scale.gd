extends Control

@export var beatScale: float = 1.1

func _ready():
    Beat.beat.connect(_onBeat)

func _onBeat():
    scale = Vector2(beatScale, beatScale)

    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1,1), 0.4)
