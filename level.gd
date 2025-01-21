extends Node2D

#Size in tiles
var x_size = 5 
var y_size = 5

#down down corner
var start_position = Vector2i.ZERO
#up right corner
var end_position = Vector2i(x_size, -y_size)

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_everything()
	
func _input(event):
	if event is InputEventKey:
		if event.pressed && event.keycode == 32 :
			await generate_everything()
		if event.pressed && event.keycode == 77 :
			x_size = x_size + (x_size * 0.1)
			y_size = y_size + (y_size * 0.1)
			await generate_everything()
		if event.pressed && event.keycode == 78 :
			x_size = x_size - (x_size * 0.1)
			y_size = y_size -(y_size * 0.1)
			await generate_everything()

func generate_everything():
	x_size += 1
	y_size += 1
	start_position = Vector2i(-x_size,y_size)
	end_position = Vector2i(x_size, -y_size)
	await paint_outline()
	await paint_inside()
	await generate_level()
	$the_guy.position = $TileMap.map_to_local(start_position)
	paint_path(end_position)
	$end.position = $TileMap.map_to_local(end_position)
	$end/shape.shape.radius = $TileMap.map_to_local(Vector2i.RIGHT).x / 2
	
func paint_outline():
	var outline = Vector2i(10 ,23)
	paint_flag(Vector2i(0, -y_size - 1), outline)
	paint_flag(Vector2i(0, y_size + 1), outline)
	paint_flag(Vector2i(x_size + 1, 0), outline)
	paint_flag(Vector2i(-x_size - 1, 0), outline)
	paint_flag(Vector2i(-x_size - 1, -y_size - 1), outline)
	paint_flag(Vector2i(x_size + 1, y_size + 1), outline)
	paint_flag(Vector2i(-x_size - 1, y_size + 1), outline)
	paint_flag(Vector2i(x_size + 1, -y_size - 1), outline)
	for i in range(x_size):
		var num = i + 1
		paint_flag(Vector2i(num, -y_size - 1), outline)
		paint_flag(Vector2i(-num, -y_size - 1), outline)
		paint_flag(Vector2i(num, y_size + 1), outline)
		paint_flag(Vector2i(-num, y_size + 1), outline)
	for i in range(y_size):
		var num = i + 1
		paint_flag(Vector2i(-x_size - 1, num), outline)
		paint_flag(Vector2i(-x_size - 1, -num), outline)
		paint_flag(Vector2i(x_size + 1, num), outline)
		paint_flag(Vector2i(x_size + 1, -num), outline)

func paint_inside():
	#28 18
	for x in range(x_size + 10):
		for y in range(y_size + 10):
			paint_flag(Vector2i(x , y), Vector2i(28,18))
			paint_flag(Vector2i(-x , y), Vector2i(28,18))
			paint_flag(Vector2i(x,-y), Vector2i(28,18))
			paint_flag(Vector2i(-x,-y), Vector2i(28,18))

func generate_level():
	var current_position = start_position
	paint_path(current_position)
	var movement_direction = Vector2i.RIGHT
	var going = [current_position]
	var calculating = true;
	while(calculating):
		movement_direction = get_direction(current_position)
		if has_empty_neighbors(current_position, movement_direction):
			if !has_path(current_position + movement_direction):
				paint_flag(current_position + movement_direction)
				
			var where = nowhere_to_go(current_position)
			if where == Vector2i.ZERO:
				var new_position = going.pop_back()
				if going.is_empty():
					calculating = false
					continue
				current_position = new_position
				continue
			else:
				movement_direction = where
		current_position = current_position + movement_direction
		going.push_back(current_position)
		paint_path(current_position)
		$the_guy.position = $TileMap.map_to_local(current_position)
	
func nowhere_to_go(target_position) :
	if !has_empty_neighbors(target_position, Vector2i.UP) && !is_out_of_bound(target_position + Vector2i.UP) :
		return Vector2i.UP
	if !has_empty_neighbors(target_position, Vector2i.DOWN) && !is_out_of_bound(target_position + Vector2i.DOWN) :
		return Vector2i.DOWN
	if !has_empty_neighbors(target_position, Vector2i.RIGHT) && !is_out_of_bound(target_position + Vector2i.RIGHT) :
		return Vector2i.RIGHT
	if !has_empty_neighbors(target_position, Vector2i.LEFT) && !is_out_of_bound(target_position + Vector2i.LEFT) :
		return Vector2i.LEFT
	return Vector2i.ZERO
	
func has_empty_neighbors(origin_position, movement_direction):
	if has_path(origin_position + movement_direction):
		return true
	var target_position = origin_position + movement_direction;
	
	var left_nei = target_position + Vector2i.LEFT
	var right_nei = target_position + Vector2i.RIGHT
	var down_nei = target_position + Vector2i.DOWN
	var up_nei = target_position + Vector2i.UP
	
	if movement_direction != Vector2i.RIGHT && (has_path(left_nei)):
		return true
	if movement_direction != Vector2i.LEFT && (has_path(right_nei)):
		return true
	if movement_direction != Vector2i.UP && (has_path(down_nei)):
		return true
	if movement_direction != Vector2i.DOWN && (has_path(up_nei)):
		return true
	return false
		
func has_path(target_position):
	var source_id = $TileMap.get_cell_source_id(0, target_position)
	return source_id == -1
	
func paint_path(current_position):
	$TileMap.set_cell(0, current_position, -1)
	
func paint_flag(current_position, map_vector = Vector2i(15,16)):
	$TileMap.set_cell(0, current_position, 0, map_vector)
	
func get_direction(current_position):
	var possible = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
	]
	
	var to_use = []
	for direction in possible:
		var target_position = current_position + direction
		if is_out_of_bound(target_position):
			continue
		to_use.push_back(direction)
			
	return to_use.pick_random()
func is_out_of_bound(target_position):
	return target_position.x > x_size || target_position.x < -x_size || target_position.y > y_size || target_position.y < -y_size
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_zoom_out_pressed():
	if $the_guy/Camera2D.zoom.x <= 1 :
		return
	$the_guy/Camera2D.zoom = $the_guy/Camera2D.zoom - Vector2(1,1)


func _on_zoom_in_pressed():
	if $the_guy/Camera2D.zoom.x >= 5 :
		return
	$the_guy/Camera2D.zoom = $the_guy/Camera2D.zoom + Vector2(1,1)


func _on_end_body_entered(body):
	if body.name == 'the_guy' :
		generate_everything()
