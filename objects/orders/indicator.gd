@tool
extends Node2D

# Draws a point where the orders will land

func _draw():
    if Engine.is_editor_hint():
        draw_line(Vector2(0, 0), Vector2(0, -60), Color(1, .2, .2), 2)
        draw_circle(Vector2(0, -60), 4, Color(.2, 1, .2))

        for i in range(5):
            draw_circle(Vector2(0, -60 - i*30), 4, Color(.2, .2, 1, .4))
