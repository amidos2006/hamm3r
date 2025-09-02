extends Node3D

var _tile_scene = preload("res://spaceship/tile.tscn")

func _ready():
	var graphs = []
	for i in range(10):
		graphs.append($MissionGenerator.generate_mission())
	#var result = LayoutGenerator._mission_to_layout(graph, 
		#[23, 12, 54, 1, 0, 5, 2, 5, 8, 3, 10, 42, 13, 57, 2, 4, 5, 6, 9, 10], 
		#"Start", "End", "Blocked")
	#print(str(result))
	var result = LayoutGenerator.generate_best_layout(graphs, 10, "Start", "End", "Blocked")
	print(result)
	var layout = result["layout"].spaceship()
	for y in layout.size():
		for x in layout[y].size():
			var cell = layout[y][x]
			var tile = _tile_scene.instantiate()
			if cell:
				tile.select_tile(
						cell.doors[LayoutGenerator.LayoutDirection.South] != LayoutGenerator.LayoutDoor.Wall, 
						cell.doors[LayoutGenerator.LayoutDirection.East] != LayoutGenerator.LayoutDoor.Wall, 
						cell.doors[LayoutGenerator.LayoutDirection.North] != LayoutGenerator.LayoutDoor.Wall, 
						cell.doors[LayoutGenerator.LayoutDirection.West] != LayoutGenerator.LayoutDoor.Wall,
				)
				tile.position = Vector3((x - layout[y].size() / 2) * 8, 0, (y - layout.size() / 2) * 8)
				add_child(tile)
	
	
