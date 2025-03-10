extends Node2D

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
