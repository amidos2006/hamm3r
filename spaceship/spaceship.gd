extends Node3D

@export var mission_generator_1:Mission
@export var mission_generator_2:Mission
@export var tile_size:Vector2 = Vector2(6, 6)
@export var computer:Node3D
@export_range(1, 20, 1) var graph_size:int = 10
@export_range(1, 20, 1) var layout_size:int = 10
@export_range(0, 1, 0.05) var door_prob:Array[float] = [0.4, 0.8, 1.0]
@export_range(0, 1, 0.05) var door_open_prob:float = 0.25


var _tile_scene = preload("res://spaceship/tile.tscn")
var _door_scene = preload("res://interactable/ship_door/ship_door.tscn")
var _groups = []
var _player = null


func _ready():
	var fitness = 0
	var result = null
	while fitness < 5:
		print("Trial")
		var graphs = []
		for i in range(graph_size):
			graphs.append(self._generate_mission())
		#var result = LayoutGenerator._mission_to_layout(graph, 
			#[23, 12, 54, 1, 0, 5, 2, 5, 8, 3, 10, 42, 13, 57, 2, 4, 5, 6, 9, 10], 
			#"Start", "End", "Blocked")
		result = LayoutGenerator.generate_best_layout(graphs, layout_size, "Start", "End", "Blocked")
		fitness = result["fitness"]
	print(str(result))
	var offset = result["start"]
	var layout = result["layout"].spaceship()
	
	var start_opening = {
		LayoutGenerator.LayoutDirection.South: false,
		LayoutGenerator.LayoutDirection.North: false,
		LayoutGenerator.LayoutDirection.East: false,
		LayoutGenerator.LayoutDirection.West: false 
	}
	var rotation_angle = Vector3()
	if offset.y == layout.size() - 1:
		rotation_angle.y = 0
		start_opening[LayoutGenerator.LayoutDirection.South] = true
	elif offset.y == 0:
		rotation_angle.y = 180
		start_opening[LayoutGenerator.LayoutDirection.North] = true
	elif offset.x == 0:
		rotation_angle.y = 90
		start_opening[LayoutGenerator.LayoutDirection.West] = true
	elif offset.x == layout[0].size() - 1:
		rotation_angle.y = -90
		start_opening[LayoutGenerator.LayoutDirection.East] = true
	computer.setup_ship(layout, offset, start_opening.find_key(true))
	var doors = []
	for y in layout.size():
		for x in layout[y].size():
			var cell = layout[y][x]
			var tile = _tile_scene.instantiate()
			if cell:
				var room_type = ""
				if cell.mission:
					room_type = cell.mission.type.to_lower()
				var temp_opening = {}
				for key in start_opening:
					if cell.mission != null and cell.mission.type == "Start":
						temp_opening[key] = start_opening[key]
					else:
						temp_opening[key] = false
				tile.select_tile(
					cell.doors[LayoutGenerator.LayoutDirection.South] != LayoutGenerator.LayoutDoor.Wall or temp_opening[LayoutGenerator.LayoutDirection.South], 
					cell.doors[LayoutGenerator.LayoutDirection.East] != LayoutGenerator.LayoutDoor.Wall or temp_opening[LayoutGenerator.LayoutDirection.East], 
					cell.doors[LayoutGenerator.LayoutDirection.North] != LayoutGenerator.LayoutDoor.Wall or temp_opening[LayoutGenerator.LayoutDirection.North], 
					cell.doors[LayoutGenerator.LayoutDirection.West] != LayoutGenerator.LayoutDoor.Wall or temp_opening[LayoutGenerator.LayoutDirection.West],
					room_type
				)
				tile.position = Vector3((x - offset.x) * tile_size.x, 0, (y - offset.y) * tile_size.y)
				self.add_child(tile)
				if self._add_door(layout, tile, x, y, LayoutGenerator.LayoutDirection.South):
					doors.append({"loc": Vector2(x, y), "dir": LayoutGenerator.LayoutDirection.South})
				if self._add_door(layout, tile, x, y, LayoutGenerator.LayoutDirection.East):
					doors.append({"loc": Vector2(x, y), "dir": LayoutGenerator.LayoutDirection.East})
				layout[y][x].tile = tile
	
	for door in doors:
		var loc = door["loc"]
		var delta = LayoutGenerator._relative_from_direction(door["dir"])
		layout[loc.y][loc.x].connect_to(layout[loc.y+delta.y][loc.x+delta.x], LayoutGenerator.LayoutDoor.Wall)
	
	var color_layout = []
	var start_locs = []
	for y in layout.size():
		color_layout.append([])
		for x in layout[y].size():
			color_layout[y].append(-1)
			if layout[y][x] != null and layout[y][x].mission != null:
				start_locs.append(Vector2(x, y))
	var color_index = 0
	for loc in start_locs:
		if self._color_map(layout, color_layout, loc.x, loc.y, color_index):
			color_index += 1
	
	self._groups = []
	for i in range(color_index):
		self._groups.append([])
	for y in layout.size():
		for x in layout[y].size():
			if color_layout[y][x] != -1:
				self._groups[color_layout[y][x]].append(layout[y][x].tile)
	for group in self._groups:
		if group.size() > 1:
			group.shuffle()
			for i in range(max(1, int(group.size() / 2) - 1)):
				var light = group[i].get_node("OmniLight3D")
				light.queue_free()
	
	self.rotation_degrees = rotation_angle
	self.position.z = -0.5 * tile_size.y
	self._player = get_node("../StartArea/Player")


func _color_map(layout, color_map, x, y, index):
	if color_map[y][x] != -1:
		return false
	var queue = [Vector2(x, y)]
	while queue.size() > 0:
		var loc = queue.pop_front()
		if color_map[loc.y][loc.x] != -1:
			continue
		color_map[loc.y][loc.x] = index
		for dir in LayoutGenerator.LayoutDirection.values():
			if layout[loc.y][loc.x].doors[dir] == LayoutGenerator.LayoutDoor.Wall:
				continue
			queue.append(loc + LayoutGenerator._relative_from_direction(dir))
	return true


func _add_door(layout, tile, x, y, direction):
	var current_cell = layout[y][x]
	if current_cell.doors[direction] == LayoutGenerator.LayoutDoor.Wall:
		return
	var delta = LayoutGenerator._relative_from_direction(direction)
	var next_cell = layout[y + delta.y][x + delta.x]
	var is_final = current_cell != null and current_cell.mission != null and current_cell.mission.type.to_lower() == "end"
	is_final = is_final or (next_cell != null and next_cell.mission != null and next_cell.mission.type.to_lower() == "end")
	
	var create_door = false
	var is_open = false
	if current_cell.get_connections() >= 2 or next_cell.get_connections() >= 2:
		var index = min(current_cell.get_connections() - 2, self.door_prob.size())
		create_door = create_door or randf() < self.door_prob[index]
		is_open = randf() < self.door_open_prob
	var forced_door = false
	if current_cell.mission != null:
		forced_door = forced_door or current_cell.mission.type == "End" or current_cell.mission.type == "Health"
	if next_cell.mission != null:
		forced_door = forced_door or next_cell.mission.type == "End" or next_cell.mission.type == "Health"
	if current_cell.mission != null or next_cell.mission != null:
		forced_door = forced_door or current_cell.get_connections() == 1 or next_cell.get_connections() == 1
	
	create_door = create_door or forced_door
	is_open = is_open and not forced_door
	if current_cell.mission != null and next_cell.mission != null and current_cell.mission.type == "Health" and next_cell.mission.type == "Health":
		create_door = false
	
	if create_door:
		var door = _door_scene.instantiate()
		door.position.x = delta.x * tile_size.x / 2
		door.position.z = delta.y * tile_size.y / 2
		if abs(delta.x) > 0:
			door.rotation_degrees.y = 90
		door.initialize(current_cell.doors[direction] == LayoutGenerator.LayoutDoor.Broken, is_open, is_final)
		tile.add_child(door)
	
	return create_door and not is_open


func _generate_mission():
	var graph_1 = mission_generator_1.generate_graph()
	var graph_2 = mission_generator_2.generate_graph()
	var pcg_graph = MissionGenerator.combine_graphs(graph_1, graph_2, "Start", "End", "Health")
	return pcg_graph
	
	
func _get_group_order(pos):
	var distances = []
	for index in range(self._groups.size()):
		var min_dist = 10000000
		var group = self._groups[index]
		for tile in group:
			var dist = (pos - tile.global_position).length()
			if dist < min_dist:
				min_dist = dist
		distances.append({"index": index, "dist": min_dist})
	distances.sort_custom(func(a, b): return a["dist"] < b["dist"])
	return distances
	
	
func _process(_delta):
	var group_orders = self._get_group_order(self._player.global_position)
	for i in range(self._groups.size()):
		var group = self._groups[i]
		for tile in group:
			if tile.has_node("OmniLight3D"):
				tile.get_node("OmniLight3D").visible = false
		if i == group_orders[0]["index"] or i == group_orders[1]["index"]:
			for tile in group:
				if tile.has_node("OmniLight3D"):
					tile.get_node("OmniLight3D").visible = true
		
