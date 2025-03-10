extends Resource
class_name Mission

@export var start_graph:JSON
@export var recipe:JSON
@export var patterns:Array[JSON]
@export var max_children:int
@export var verbose:bool

func _init():
	start_graph = null
	recipe = null
	patterns = []
	max_children = 3
	verbose = false
	
func generate_graph():
	MissionGenerator.verbose = self.verbose
	return MissionGenerator.generate_dungeon(self.start_graph, self.recipe, self.patterns, self.max_children)
