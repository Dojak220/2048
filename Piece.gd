extends ColorRect

# Called when the node enters the scene tree for the first time.
#func _ready():
#	set_label(100, Color(1,1,1))
#	pass # Replace with function body.

func set_label(lb_text, lb_size, lb_color):
	$PieceValue.text = lb_text
	$PieceValue.get("custom_fonts/font").set_size(lb_size)
	$PieceValue.add_color_override("font_color", lb_color)
