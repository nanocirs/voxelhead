extends Node2D
 
@export var texture: Texture2D
@export var brush_size: int = 100
 
var brush_queue = []
 

func queue_brush(position: Vector2, color: Color):
	brush_queue.push_back([position, color])
	queue_redraw()
 
func _draw():
	for b in brush_queue:
		draw_texture_rect(texture, Rect2(b[0].x - brush_size/2, b[0].y - brush_size/2, brush_size, brush_size), false, b[1])
	brush_queue = []
