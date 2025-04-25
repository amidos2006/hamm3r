extends Node3D

@export var mission_generator_1:Mission
@export var mission_generator_2:Mission
@export var fixed_start:JSON
	
func generate_mission():
	var graph_1 = mission_generator_1.generate_graph()
	var graph_2 = mission_generator_2.generate_graph()
	var pcg_graph = MissionGenerator.combine_graphs(graph_1, graph_2, "Start", "End", "Health")
	return pcg_graph
