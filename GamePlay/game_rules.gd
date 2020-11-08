extends Node

const MAP_SIZE = 4
const NEW_BRICKS = [2 , 4]
const BRICK_PERC = 0.85
const INPUTS = {
	"ui_right": Vector2.RIGHT,   # Vector2( 1,  0)
	"ui_left": Vector2.LEFT,     # Vector2(-1,  0)
	"ui_up": Vector2.UP,         # Vector2( 0,  1)
	"ui_down": Vector2.DOWN      # Vector2( 0, -1)
}     
const COLORS = {
	0 : Color(0.8, 0.75, 0.71, 1),
	2 : Color(0.95, 0.95, 0.90, 0.6),
	4 : Color(0.95, 0.95, 0.90, 0.8),
	8 : Color(0.4, 0.7, 0.2, 0.6),
	16 : Color(0.4, 0.7, 0.2, 1),
	32 : Color(0.4, 0.2, 0.9, 0.4),
	64 : Color(0.4, 0.2, 0.9, 1),
	128 : Color(0.9, 0, 0.3, 0.4),
	256 : Color(0.9, 0, 0.3, 0.7),
	512 : Color(0.9, 0, 0.3, 1),
	1024 : Color(0.9, 0.9, 0.1, 0.6),
	2048 : Color(0.9, 0.9, 0.1, 1),
}

# VARIABLES
var occupation_map
var can_insert = false                   # True when a moviment changes the map
var map_changed = true




# SIGNALS
signal new_value_inserted #unused for now

# FUNÇÕES
func _ready():
	occupation_map = create_map(MAP_SIZE, MAP_SIZE, 0)
	print_map()
	
	insert_new_value()
	insert_new_value()
	
	print_map()

func create_map(height, width, value):
	var map = []

	for x in range(height):
		var line = []
		line.resize(width)
		map.append(line)
		for y in range(width):
			map[x][y] = {"value": 0, "clean": true}
			
	return map

func print_map():
	var line = ""
	for i in range(MAP_SIZE):
		for j in range(MAP_SIZE):
			line = line + String(occupation_map[i][j].value) + " "
		print("[ ", line, "]")
		line = ""
	print("")

func insert_new_value():
	if is_fully_occupied():
		return
	
	randomize()
	
	var new_brick = NEW_BRICKS[0] if (randf() <= BRICK_PERC) else NEW_BRICKS[1]
	var line = randi() % MAP_SIZE
	var column = randi() % MAP_SIZE
	
	while(is_position_occupied(line, column)):
		line = randi() % MAP_SIZE
		column = randi() % MAP_SIZE
	
	occupation_map[line][column].value = new_brick
	
	if is_fully_occupied():
		print("Mapa cheio. Se não houver combinações possíveis... Game over")

func is_fully_occupied():
	var fully_occupied = true
	for line in occupation_map:
		for column in line:
			if !(column.value):
				fully_occupied = false
	return fully_occupied

func is_position_occupied(line, column):
	return occupation_map[line][column].value

func _unhandled_input(event):
	for dir in INPUTS.keys():
		if event.is_action_pressed(dir):
			can_insert = false
			print(dir)
			update_map(dir);
			if can_insert:
				insert_new_value()
				map_changed = true
			print_map()

func update_map(direction):
	var x_aux
	var y_aux

	if direction == "ui_right":
		for x in range(MAP_SIZE): # [0, 1, 2, 3]
			for y in range(MAP_SIZE-2,-1,-1): # [2, 1, 0]
				if (occupation_map[x][y].value != 0):
					y_aux = y
					while(y_aux < MAP_SIZE-1 && occupation_map[x][y_aux+1].value == 0):
						y_aux += 1
						occupation_map[x][y_aux].value = occupation_map[x][y_aux-1].value
						occupation_map[x][y_aux-1].value = 0
						can_insert = true
					if (y_aux == MAP_SIZE-1):
						continue
					if (occupation_map[x][y_aux+1].clean && occupation_map[x][y_aux+1].value == occupation_map[x][y_aux].value):
						occupation_map[x][y_aux+1].value *= 2
						occupation_map[x][y_aux+1].clean = false
						occupation_map[x][y_aux].value = 0
						can_insert = true
	
	if direction == "ui_left":
		for x in range(MAP_SIZE): # [0, 1, 2, 3]
			for y in range(1, MAP_SIZE): # [1, 2, 3]
				if (occupation_map[x][y].value != 0):
					y_aux = y
					while(y_aux > 0 && occupation_map[x][y_aux-1].value == 0):
						y_aux -= 1
						occupation_map[x][y_aux].value = occupation_map[x][y_aux+1].value
						occupation_map[x][y_aux+1].value = 0
						can_insert = true
					if (y_aux == 0):
						continue
					if (occupation_map[x][y_aux-1].clean && occupation_map[x][y_aux-1].value == occupation_map[x][y_aux].value):
						occupation_map[x][y_aux-1].value *= 2
						occupation_map[x][y_aux-1].clean = false
						occupation_map[x][y_aux].value = 0
						can_insert = true
	
	if direction == "ui_up":
		for y in range(MAP_SIZE): # [0, 1, 2, 3]
			for x in range(1, MAP_SIZE): # [1, 2, 3]
				if (occupation_map[x][y].value != 0):
					x_aux = x
					while(x_aux > 0 && occupation_map[x_aux-1][y].value == 0):
						x_aux -= 1
						occupation_map[x_aux][y].value = occupation_map[x_aux+1][y].value
						occupation_map[x_aux+1][y].value = 0
						can_insert = true
					if (x_aux == 0):
						continue
					if (occupation_map[x_aux-1][y].clean && occupation_map[x_aux-1][y].value == occupation_map[x_aux][y].value):
						occupation_map[x_aux-1][y].value *= 2
						occupation_map[x_aux-1][y].clean = false
						occupation_map[x_aux][y].value = 0
						can_insert = true
	
	if direction == "ui_down":
		for y in range(MAP_SIZE): # [0, 1, 2, 3]
			for x in range(MAP_SIZE-2,-1,-1): # [2, 1, 0]
				if (occupation_map[x][y].value != 0):
					x_aux = x
					while(x_aux < MAP_SIZE-1 && occupation_map[x_aux+1][y].value == 0):
						x_aux += 1
						occupation_map[x_aux][y].value = occupation_map[x_aux-1][y].value
						occupation_map[x_aux-1][y].value = 0
						can_insert = true
					if (x_aux == MAP_SIZE-1):
						continue
					if (occupation_map[x_aux+1][y].clean && occupation_map[x_aux+1][y].value == occupation_map[x_aux][y].value):
						occupation_map[x_aux+1][y].value *= 2
						occupation_map[x_aux+1][y].clean = false
						occupation_map[x_aux][y].value = 0
						can_insert = true
	
	clean_map()

func clean_map():
	for x in range(MAP_SIZE): # [0, 1, 2, 3]
			for y in range(MAP_SIZE): # [0, 1, 2, 3]
				occupation_map[x][y].clean = true

func update_screen():
	var label_path
	var tile_path
	for i in range(MAP_SIZE):
		for j in range(MAP_SIZE):
			tile_path = "ScreenBG/ScreenMargin/ScreenVBox/GameCenter/GameBG/" + String(i) + "-" + String(j) + "BG"
#			$"ScreenBG/ScreenMargin/ScreenVBox/GameCenter/GameBG/0-0BG/0-0Text".add_color_override("font_color")= Color(255,255,100,occupation_map[i][j].value / 2048)
			label_path = "ScreenBG/ScreenMargin/ScreenVBox/GameCenter/GameBG/" + String(i) + "-" + String(j) + "BG/" + String(i) + "-" + String(j) + "Text"
			
			get_node(NodePath(label_path)).text = "" if !occupation_map[i][j].value else String(occupation_map[i][j].value)
			get_node(NodePath(label_path)).get("custom_fonts/font").set_size(48)
			get_node(NodePath(tile_path)).color = COLORS[occupation_map[i][j].value]
			
			if occupation_map[i][j].value > 4 && occupation_map[i][j].value < 1024:
				get_node(NodePath(label_path)).add_color_override("font_color", Color(1, 1, 1, 1))
			else:
				get_node(NodePath(label_path)).add_color_override("font_color", Color(0.47, 0.43, 0.4, 1))

			
			if occupation_map[i][j].value > 100:
				if occupation_map[i][j].value > 1000:
					get_node(NodePath(label_path)).get("custom_fonts/font").set_size(32)
				else:
					get_node(NodePath(label_path)).get("custom_fonts/font").set_size(40)
	
	map_changed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(map_changed):
		update_screen()
	pass
