extends Node3D

@export var mission_generator_1:Mission
@export var mission_generator_2:Mission
@export var fixed_start:JSON
@export var tile_size:Vector2 = Vector2(6, 6)
@export_range(0, 1, 0.05) var door_prob:Array[float] = [0.4, 0.8, 1.0]
@export_range(0, 1, 0.05) var door_open_prob:float = 0.25


var _tile_scene = preload("res://spaceship/tile.tscn")
var _door_scene = preload("res://interactable/ship_door/ship_door.tscn")


func _ready():
	var fitness = 0
	var result = null
	while fitness < 2:
		var graphs = []
		for i in range(10):
			graphs.append(self._generate_mission())
		#var result = LayoutGenerator._mission_to_layout(graph, 
			#[23, 12, 54, 1, 0, 5, 2, 5, 8, 3, 10, 42, 13, 57, 2, 4, 5, 6, 9, 10], 
			#"Start", "End", "Blocked")
		result = LayoutGenerator.generate_best_layout(graphs, 10, "Start", "End", "Blocked")
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
				self._add_door(layout, tile, x, y, LayoutGenerator.LayoutDirection.South)
				self._add_door(layout, tile, x, y, LayoutGenerator.LayoutDirection.East)
				
	self.rotation_degrees = rotation_angle
	self.position.z = -0.5 * tile_size.y
	
	
func _add_door(layout, tile, x, y, direction):
	var current_cell = layout[y][x]
	if current_cell.doors[direction] == LayoutGenerator.LayoutDoor.Wall:
		return
	var delta = LayoutGenerator._relative_from_direction(direction)
	var next_cell = layout[y + delta.y][x + delta.x]
	
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
		door.initialize(current_cell.doors[direction] == LayoutGenerator.LayoutDoor.Broken, is_open)
		tile.add_child(door)
	


func _generate_mission():
	var graph_1 = mission_generator_1.generate_graph()
	var graph_2 = mission_generator_2.generate_graph()
	var pcg_graph = MissionGenerator.combine_graphs(graph_1, graph_2, "Start", "End", "Health")
	return pcg_graph
