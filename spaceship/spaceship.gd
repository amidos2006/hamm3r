extends Node3D

@export var mission_generator_1:Mission
@export var mission_generator_2:Mission
@export var fixed_start:JSON
@export var tile_size:Vector2 = Vector2(6, 6)


var _tile_scene = preload("res://spaceship/tile.tscn")


func _ready():
	var graphs = []
	for i in range(10):
		graphs.append(self._generate_mission())
	#var result = LayoutGenerator._mission_to_layout(graph, 
		#[23, 12, 54, 1, 0, 5, 2, 5, 8, 3, 10, 42, 13, 57, 2, 4, 5, 6, 9, 10], 
		#"Start", "End", "Blocked")
	var result = LayoutGenerator.generate_best_layout(graphs, 10, "Start", "End", "Blocked")
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
					if cell.mission.type == "End":
						room_type = "end"
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
				add_child(tile)
	self.rotation_degrees = rotation_angle
	self.position.z = -0.5 * tile_size.y
	
	
func _generate_mission():
	var graph_1 = mission_generator_1.generate_graph()
	var graph_2 = mission_generator_2.generate_graph()
	var pcg_graph = MissionGenerator.combine_graphs(graph_1, graph_2, "Start", "End", "Health")
	return pcg_graph
