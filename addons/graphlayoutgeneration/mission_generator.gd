class_name MissionGenerator
extends RefCounted


static var verbose = false


static func _get_permutations(values, size):
	var result = []
	if size == 0:
		return result
	for i in range(values.size()):
		var clone = []
		clone.append_array(values)
		clone.remove_at(i)
		var tempResult = _get_permutations(clone, size - 1)
		if tempResult.size() == 0:
			result.append([]);
			result[result.size() - 1].append(values[i])
		for list in tempResult:
			list.push_front(values[i])
			result.append(list)
	return result
	

static func _shuffle(array, rng):
	for i in array.size() - 2:
		var j = rng.randi_range(i, array.size() - 1)
		var tmp = array[i]
		array[i] = array[j]
		array[j] = tmp
		
	
static func generate_dungeon(start_graph, recipe, patterns, max_connections = 4, random = null):
	if random == null:
		random = RandomNumberGenerator.new()
		random.randomize()
	var graph = MissionGraph.load_graph(start_graph.get_data())
	var actions = {}
	for pattern in patterns:
		var name = pattern.resource_path.get_file().trim_suffix('.json')
		actions[name] = MissionPattern.load_pattern(random, pattern)
	var plan = MissionRecipe.load_recipe(random, actions, recipe)
	plan.apply_recipe(graph, max_connections)
	return graph
	

static func combine_graphs(graph1, graph2, start_name = "Start", end_name = "End", new_name = "Middle"):
	var new_graph = MissionGraph.new()
	var middle_node = null
	for node in graph1.nodes:
		var type = node.type
		if node.type == end_name.strip_edges():
			type = new_name.strip_edges()
		new_graph.nodes.append(MissionNode.new(node.id, node.access_level, type))
		if node.type == end_name.strip_edges():
			middle_node = new_graph.nodes[-1]
	for i in range(graph1.nodes.size()):
		var children = graph1.nodes[i].get_children()
		for child in children:
			var index = graph1.get_node_index(child)
			new_graph.nodes[i].connect_to(new_graph.nodes[index])
	new_graph.nodes.append(MissionNode.new(graph1.nodes.size(), middle_node.access_level, new_name))
	middle_node.connect_to(new_graph.nodes[-1])
	middle_node = new_graph.nodes[-1]
	var start_id = graph1.nodes.size()
	var start_access = middle_node.access_level + 1
	for node in graph2.nodes:
		if node.type == start_name.strip_edges():
			continue
		new_graph.nodes.append(MissionNode.new(node.id + start_id, node.access_level + start_access, node.type))
	for i in range(graph2.nodes.size()):
		var node = new_graph.nodes[i + start_id]
		if graph2.nodes[i].type == start_name.strip_edges():
			node = middle_node
		var children = graph2.nodes[i].get_children()
		for child in children:
			var index = graph2.get_node_index(child)
			node.connect_to(new_graph.nodes[index + start_id])
	return new_graph
	

class MissionNode extends RefCounted:
	var id
	var access_level
	var type
	var _links
	
	
	func _init(id, access_level, type):
		self.id = id
		self.access_level = access_level
		self.type = type
		self._links = []
		
	
	func get_children():
		var result = []
		for node in self._links:
			result.append(node)
		return result
		
	
	func get_filtered_children(graph):
		return self.get_children().filter(
			func(value): return graph.get_node_index(value) >= 0
		)
		
	
	func adjust_access_level(new_level):
		if self.access_level == new_level:
			return
		self.access_level = new_level;
		if self.type != "Valve":
			var children = self.get_children()
			for c in children:
				if c.type.contains("Lock"):
					c.adjust_access_level(new_level + 1)
				else:
					c.adjust_access_level(new_level)
					
	
	func connect_to(node):
		self._links.append(node)
		
	
	func remove_links(node, two_ways=true):
		self._links = self._links.filter(
			func(value): return value != node
		)
		if two_ways:
			node.remove_links(self, false)
			
	
	func is_node_equal(node, access_modification = 0):
		if self.access_level + access_modification == node.access_level:
			return self.type == "Any" or node.type == "Any" or self.type == node.type
		return false;
	
	
	func _to_string():
		var result = "Node " + str(self.id) + " is " + self.type + "_" + str(self.access_level)
		var children = self.get_children()
		if children.size() > 0:
			result += " connections: "
		for  c in children:
			result += str(c.id) + " "
		result += "\n"
		return result


class MissionGraph extends RefCounted:
	var nodes
	var relative_access
	
	
	func _init():
		self.nodes = []
		self.relative_access = 0
		
	
	static func load_graph(graph_data):
		var result = MissionGraph.new()
		var nodeDictionary = {}
		for node in graph_data["nodes"]:
			nodeDictionary[node["id"]] = MissionNode.new(node["id"], node["access"], node["type"].strip_edges())
		for edge in graph_data["edges"]:
			nodeDictionary[edge["start"]].connect_to(nodeDictionary[edge["end"]])
		for id in nodeDictionary:
			result.nodes.append(nodeDictionary[id])
		return result
		
	
	func get_nodes(type):
		var result = []
		for n in nodes:
			if n.type == type:
				result.append(n)
		return result
		
	
	func get_num_connections(node):
		var result = node.get_children().size()
		var queue = []
		queue.append(node)
		var visited = {}
		while queue.size() > 0:
			var current = queue[0];
			queue.erase(current);
			if visited.has(current.get_instance_id()):
				continue
			visited[current.get_instance_id()] = null;
			if current == node:
				result += 1
			for child in current.get_children():
				queue.append(child);
		return result - 1;
		
	
	func get_node_index(node):
		return self.nodes.find(node)
		
	
	func get_permutations(size):
		var indeces = range(self.nodes.size())
		var integerPermutations = MissionGenerator._get_permutations(indeces, size);
		var nodePermutations = []
		for list in integerPermutations:
			var temp = MissionGraph.new()
			for i in range(list.size()):
				temp.nodes.append(self.nodes[list[i]])
			nodePermutations.append(temp)
		return nodePermutations
		
	
	func get_highest_access_level():
		var max_value = 0
		for n in self.nodes:
			if n.access_level > max_value:
				max_value = n.access_level
		return max_value
		
	
	func check_similarity(graph):
		for i in range(self.nodes.size()):
			if not self.nodes[i].is_node_equal(graph.nodes[i], self.relative_access - graph.relative_access):
				return false
			var p_child = self.nodes[i].get_filtered_children(self)
			var g_child = graph.nodes[i].get_filtered_children(graph)
			if g_child.size() != p_child.size():
				return false
			var testing = []
			for j in range(p_child.size()):
				testing.append(self.get_node_index(p_child[j]))
			for j in range(g_child.size()):
				var g_index = graph.get_node_index(g_child[j])
				if testing.find(g_index) < 0:
					return false
				testing.erase(g_index)
			if testing.size() > 0:
				return false
		return true
		
	
	func _to_string():
		var result = "Graph:\n";
		for n in self.nodes:
			result += "\t" + str(n)
		return result;
		

class MissionPattern extends RefCounted:
	var _random
	var _pattern_match
	var _pattern_apply
	
	
	func _init(random):
		self._random = random
		self._pattern_match = MissionGraph.new()
		self._pattern_apply = []
		
	
	static func load_pattern(random, json_object):
		var result = MissionPattern.new(random)
		var json_data = json_object.get_data()
		result._pattern_match = MissionGraph.load_graph(json_data["input"])
		result._pattern_apply = []
		for graph in json_data["outputs"]:
			result._pattern_apply.append(MissionGraph.load_graph(graph))
		return result
			
	
	func _check_pattern_applicable(graph, max_value = 4):
		for i in range(self._pattern_match.nodes.size()):
			for pattern_output in self._pattern_apply:
				if self._pattern_match.nodes[i].get_children().size() < pattern_output.nodes[i].get_children().size():
					if graph.get_num_connections(graph.nodes[i]) >= max_value:
						return false
		return true
		
	
	func apply_pattern(graph, max_connections = 4):
		var permutations = graph.get_permutations(self._pattern_match.nodes.size());
		MissionGenerator._shuffle(permutations, self._random)
		var max_access_level = graph.get_highest_access_level()
		var levels = range(max_access_level + 1)
		MissionGenerator._shuffle(levels, self._random)
		var selected_subgraph = MissionGraph.new()
		for subgraph in permutations:
			for level in levels:
				self._pattern_match.relative_access = level
				if self._pattern_match.check_similarity(subgraph) and self._check_pattern_applicable(subgraph, max_connections):
					selected_subgraph = subgraph;
					break
			if selected_subgraph.nodes.size() > 0:
				break
		if selected_subgraph.nodes.size() == 0:
			return
		for n in selected_subgraph.nodes:
			var children = n.get_filtered_children(selected_subgraph)
			for c in children:
				n.remove_links(c)
		var selected_pattern = self._pattern_apply[self._random.randi_range(0, self._pattern_apply.size() - 1)]
		for i in range(selected_subgraph.nodes.size()):
			if selected_pattern.nodes[i].type != "Any":
				selected_subgraph.nodes[i].type = selected_pattern.nodes[i].type
		for i in range(selected_subgraph.nodes.size(), selected_pattern.nodes.size()):
			var new_node = MissionNode.new(graph.nodes.size(), -1, selected_pattern.nodes[i].type)
			graph.nodes.append(new_node)
			selected_subgraph.nodes.append(new_node)
		for i in range(selected_pattern.nodes.size()):
			selected_subgraph.nodes[i].adjust_access_level(self._pattern_match.relative_access + selected_pattern.nodes[i].access_level)
			var children = selected_pattern.nodes[i].get_children()
			for c in children:
				var index = selected_pattern.get_node_index(c)
				selected_subgraph.nodes[i].connect_to(selected_subgraph.nodes[index])
		

class MissionRecipeAction extends RefCounted:
	var _random
	var action
	var minimum
	var maximum
	
	func _init(random, action, minimum, maximum):
		self._random = random
		self.action = action
		self.minimum = minimum
		self.maximum = maximum
		
	
	static func load_recipe_action(random, patterns, json_data):
		var value = 1
		if json_data.has("value"):
			value = json_data["value"]
		if json_data.has("minimum"):
			value = json_data["minimum"]
		var minimum = value
		var maximum = value
		if json_data.has("maximum"):
			maximum = json_data["maximum"]
		if maximum < minimum:
			var temp = minimum
			minimum = maximum
			maximum = temp
		return MissionRecipeAction.new(random, patterns[json_data["name"]], minimum, maximum)
		
	
	func apply_action(graph, max_connections = 4):
		var count = self._random.randi_range(self.minimum, self.maximum)
		for i in range(count):
			self.action.apply_pattern(graph, max_connections)
		

class MissionRecipe extends RefCounted:
	var actions
	
	func _init():
		self.actions = []
		
	
	static func load_recipe(random, patterns, json_object):
		var json_data = json_object.get_data()
		var result = MissionRecipe.new()
		for action in json_data:
			result.actions.append(MissionRecipeAction.load_recipe_action(random, patterns, action))
		return result
		
	
	func apply_recipe(graph, maximum_connections = 4):
		for action in self.actions:
			action.apply_action(graph, maximum_connections)
			if MissionGenerator.verbose:
				print("######## Step ########")
				print(str(graph))
