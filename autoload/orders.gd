extends Node2D

# Stores failed orders. Succeded orders are stored in the associated pizza.

func _ready():
    if not Engine.is_editor_hint(): hide()
