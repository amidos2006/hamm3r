class_name LayoutGenerator
extends RefCounted


static var verbose = false


enum LayoutDirection{
	North,
	South,
	East,
	West,
}


enum LayoutDoor{
	Wall,
	Normal,
	Broken,
}


static func _reverse_direction(direction):
	if direction == LayoutDirection.North:
		return LayoutDirection.South
	if direction == LayoutDirection.South:
		return LayoutDirection.North
	if direction == LayoutDirection.East:
		return LayoutDirection.West
	if direction == LayoutDirection.West:
		return LayoutDirection.East
	return -1
	

static func _relative_from_direction(direction):
	if direction == LayoutDirection.North:
		return Vector2(0, -1)
	if direction == LayoutDirection.South:
		return Vector2(0, 1)
	if direction == LayoutDirection.East:
		return Vector2(1, 0)
	if direction == LayoutDirection.West:
		return Vector2(-1, 0)
	return Vector2(0, 0)
	

static func _direction_from_relative(x, y):
	if x < 0 and y == 0:
		return LayoutDirection.West
	if x > 0 and y == 0:
		return LayoutDirection.East
	if x == 0 and y < 0:
		return LayoutDirection.North
	if x == 0 and y > 0:
		return LayoutDirection.South
	return -1
	

static func _shortest_path(sx, sy, ex, ey, maze, penelaty=10, max_iterations=100):
	var start_cell = maze.get_cell(sx, sy)
	var queue = [{"pos": Vector2(sx, sy), "value": 0, "parent": null}]
	var visited = {}
	var iterations = 0
	while len(queue) > 0 and iterations < max_iterations:
		queue.sort_custom(func(a,b): a["value"] < b["value"])
		var c = queue.pop_front()
		if c["pos"].x == ex and c["pos"].y == ey:
			var result = []
			while c != null:
				result.append(c["pos"])
				c = c["parent"]
			result.reverse()
			return result
		if visited.has(LayoutGenerator._location_id(c["pos"].x, c["pos"].y)):
			continue
		visited[LayoutGenerator._location_id(c["pos"].x, c["pos"].y)] = true
		for dir in LayoutDirection.values():
			var rel = LayoutGenerator._relative_from_direction(dir)
			var pos = Vector2(c["pos"].x+rel.x, c["pos"].y+rel.y)
			var value = 0
			var collision_cell = maze.get_cell(pos.x, pos.y)
			if collision_cell != null:
				if collision_cell.mission != null and collision_cell.mission.access_level > start_cell.mission.access_level:
					continue
				value = penelaty
			queue.append({
				"pos": Vector2(pos.x, pos.y),
				"value": c["value"] + value + 1,
				"parent": c
			})
		iterations += 1
	return []
	

static func _maze_2d(maze):
	var size = maze.size()
	var layout = []
	for y in range(size.y):
		layout.append([])
		for x in range(size.x):
			layout[-1].append(maze.get_cell(x, y))
	return layout
	

static func _flood_fill(maze, start, same_type_fn):
	var visited_locs = []
	var visited_map = []
	for y in range(maze.size()):
		visited_map.append([])
		for x in range(maze[y].size()):
			visited_map[-1].append(false)
	var queue = [start]
	while queue.size() > 0:
		var current = queue.pop_front()
		if visited_map[current.y][current.x]:
			continue
		visited_map[current.y][current.x] = true
		visited_locs.append(current)
		for dir in LayoutDirection.values():
			var new_pos = current + LayoutGenerator._relative_from_direction(dir)
			if new_pos.x < 0 or new_pos.y < 0 or new_pos.x >= maze[0].size() or new_pos.y >= maze.size():
				continue
			if not same_type_fn.call(maze[new_pos.y][new_pos.x]):
				continue
			queue.append(new_pos)
	return visited_locs

static func _spaceship_2d(maze, start_type="", broken_type="", end_type=""):
	var layout = LayoutGenerator._maze_2d(maze)
	var extra_blocks = []
	var start_blocks = []
	var broken_blocks = []
	
	var start_loc = []
	var end_loc = []
	var broken_loc = []
	var hole_loc = []
	var wrong_connections = []
	for y in range(layout.size()):
		for x in range(layout[y].size()):
			if x < layout[y].size() / 2:
				if layout[y][x] == null and layout[y][-x-1] != null:
					layout[y][x] = LayoutCell.new(x, y, null)
					extra_blocks.append(Vector2(x, y))
				if layout[y][x] != null and layout[y][-x-1] == null:
					layout[y][-x-1] = LayoutCell.new(layout[y].size() - x - 1, y, null)
					extra_blocks.append(Vector2(layout[y].size() - x - 1, y))
			if layout[y][x] != null and layout[y][x].mission != null and layout[y][x].mission.type == start_type:
				start_loc.append(Vector2(x, y))
			if layout[y][x] != null and layout[y][x].mission != null and layout[y][x].mission.type == end_type:
				end_loc.append(Vector2(x, y))
			if layout[y][x] != null and layout[y][x].mission != null and layout[y][x].mission.type == broken_type:
				broken_loc.append(Vector2(x, y))
			if layout[y][x] != null and layout[y][x].get_neighbors(maze).size() > 4:
				wrong_connections.append(Vector2(x, y))
	for start in start_loc:
		var min_x = min(start.x, layout[0].size() - 1 - start.x)
		var min_y = min(start.y, layout.size() - 1 - start.y)
		if min_x < min_y:
			if start.x < layout[0].size() / 2:
				for x in range(start.x+1):
					start_blocks.append(Vector2(x, start.y))
			else:
				for x in range(start.x, layout[0].size()):
					start_blocks.append(Vector2(x, start.y))
		else:
			if start.y < layout.size() / 2:
				for y in range(start.y+1):
					start_blocks.append(Vector2(start.x, y))
			else:
				for y in range(start.y, layout.size()):
					start_blocks.append(Vector2(start.x, y))
	for start in extra_blocks:
		var reach_broken = LayoutGenerator._flood_fill(layout, start, func(cell): return cell != null and ((cell.mission != null and cell.mission.type == broken_type) or cell.get_neighbors(maze).size() == 0))
		for point in reach_broken:
			for broken in broken_loc:
				if point.x == broken.x and point.y == broken.y:
					broken_blocks.append(start)
					break
	for y in range(layout.size()):
		for x in range(layout[y].size()):
			if layout[y][x] == null:
				hole_loc.append(Vector2(x, y))
	var end_connections = 0
	for end in end_loc:
		for dir in LayoutDirection.values():
			var rel = LayoutGenerator._relative_from_direction(dir)
			var pos = Vector2(end.x+rel.x, end.y+rel.y)
			if pos.x >= 0 and pos.y >= 0 and pos.x < layout[0].size() and pos.y < layout.size():
				if layout[pos.y][pos.x] != null:
					end_connections += 1
	return {"layout": layout, "extra": extra_blocks, "start": start_blocks, "start_loc": start_loc, "broken": broken_blocks, "connections": wrong_connections, "holes": hole_loc, "end_connections": end_connections}
	

static func _location_id(x, y):
	return "%d,%d" % [x, y]
	

static func _mission_to_layout(graph, expansions, start_type, end_type, broken_type):
	var errors = {
		"connections": [], 
		"placement": [],
		"missing": [],
		"extra": 0
	}
	var maze = LayoutMaze.new()
	var queue = [LayoutCell.new(0, 0, graph.get_nodes(start_type)[0])]
	maze.add_cell(queue[0])
	var visited = {}
	var index = 0
	while queue.size() > 0:
		var cell = queue.pop_front()
		if visited.has(graph.get_node_index(cell.mission)):
			continue
		visited[graph.get_node_index(cell.mission)] = cell
		var empty = maze.get_empty_cells(cell.position.x, cell.position.y)
		for m in cell.mission.get_children():
			if empty.size() == 0:
				errors["placement"].append(m.id)
				continue
			var empty_index = expansions[index % expansions.size()] % empty.size()
			var new_cell = empty[empty_index]
			if visited.has(graph.get_node_index(m)):
				new_cell = visited[graph.get_node_index(m)]
			else:
				empty.pop_at(empty_index)
				index += 1
				new_cell.mission = m
			var type = LayoutDoor.Normal
			if m.type == broken_type:
				type = LayoutDoor.Broken
			var connection = maze.connect_cells(cell, new_cell, type)
			if not connection["connect"]:
				errors["connections"].append([cell.mission.id, new_cell.mission.id])
			elif connection["extra"].size() > 0:
				errors["extra"] += connection["extra"].size()
				for e in connection["extra"]:
					maze.add_cell(e)
				var to_remove = []
				for e in empty:
					for p in connection["extra"]:
						if e.position.x == p.position.x and e.position.y == p.position.y:
							to_remove.append(e)
							break
				for e in to_remove:
					empty.erase(e)
			maze.add_cell(new_cell)
			queue.append(new_cell)
	for m in graph.nodes:
		var exist = false
		for c in maze.cells:
			if c.mission == m:
				exist = true
				break
		if not exist:
			errors["missing"].append(m.id)
	return {
		"layout": maze,
		"connections": errors["connections"],
		"placement": errors["placement"],
		"missing": errors["missing"],
		"extra": errors["extra"]
	}
	

static func generate_best_layout(graphs, size, start_type, end_type, broken_type, random=null):
	var population = []
	for g in graphs:
		for i in range(size):
			population.append(LayoutChromosome.new(g, g.nodes.size(), start_type, end_type, broken_type, random))
	population.sort_custom(func(a,b): return a.fitness() < b.fitness())
	#var ga = LayoutGA.new(graphs, size, start_type, end_type, broken_type, random)
	#for i in range(size):
		#ga.update(0,0.5,0.1,0.2,5)
	#var population = [ga.best()]
	return {"graph": population[-1]._graph, "layout": population[-1]._layout, "start": population[-1]._start, "fitness": population[-1]._fitness}
	

class LayoutCell extends RefCounted:
	var mission
	var position
	var doors
	
	
	func _init(x, y, mission = null):
		self.position = Vector2(x, y)
		self.mission = mission
		self.doors = {}
		for d in LayoutDirection.values():
			self.doors[d] = LayoutDoor.Wall
		
	
	func connect_to(cell, type, both_ways=true):
		var rel = cell.position - self.position 
		if abs(rel.x + rel.y) != 1:
			return
		self.doors[LayoutGenerator._direction_from_relative(rel.x, rel.y)] = type
		if both_ways:
			cell.connect_to(self, type, false)
	
	
	func get_connections():
		var result = 0
		for door in self.doors.values():
			if door != LayoutDoor.Wall:
				result += 1
		return result
	
	
	func get_neighbors(maze):
		var result = []
		for dir in LayoutDirection.values():
			if self.doors[dir] != LayoutDoor.Normal:
				continue
			var rel = LayoutGenerator._relative_from_direction(dir)
			result.append(maze.get_cell(self.position.x + rel.x, 
				self.position.y + rel.y))
		return result
		
	
	func get_id():
		return LayoutGenerator._location_id(self.position.x, self.position.y)
		

class LayoutMaze extends RefCounted:
	var cells
	
	func _init():
		self.cells = []
		
	
	func add_cell(cell):
		if self.get_cell(cell.position.x, cell.position.y) == null:
			self.cells.append(cell)
		
	
	func get_cell(x, y):
		var id = LayoutGenerator._location_id(x, y)
		for cell in self.cells:
			if cell.get_id() == id:
				return cell
		return null
		
	
	func get_empty_cells(x, y):
		var result = []
		for dir in LayoutDirection.values():
			var loc = LayoutGenerator._relative_from_direction(dir) + Vector2(x, y)
			if self.get_cell(loc.x, loc.y) == null:
				result.append(LayoutCell.new(loc.x, loc.y))
		return result
		
	
	func connect_cells(cell1, cell2, type):
		var path = LayoutGenerator._shortest_path(cell1.position.x, cell1.position.y, cell2.position.x, cell2.position.y, self)
		if path.size() < 2:
			return {"connect": false, "extra": []}
		var current = cell1
		var extra = []
		for p in path:
			if (p.x == cell1.position.x and p.y == cell1.position.y) or (p.x == cell2.position.x and p.y == cell2.position.y):
				continue
			var cell = self.get_cell(p.x, p.y)
			if cell == null:
				cell = LayoutCell.new(p.x, p.y)
				extra.append(cell)
			current.connect_to(cell, type)
			current = cell
		current.connect_to(cell2, type)
		return {"connect": true, "extra": extra}
		
	
	func _center():
		var minimum = Vector2(0, 0)
		for cell in self.cells:
			if cell.position.x < minimum.x:
				minimum.x = cell.position.x
			if cell.position.y < minimum.y:
				minimum.y = cell.position.y
		for cell in self.cells:
			cell.position -= minimum
		
	
	func size():
		self._center()
		var maximum = Vector2(0, 0)
		for cell in self.cells:
			if cell.position.x > maximum.x:
				maximum.x = cell.position.x
			if cell.position.y > maximum.y:
				maximum.y = cell.position.y
		return maximum + Vector2(1, 1)
		
		
	func spaceship():
		return LayoutGenerator._spaceship_2d(self)["layout"]
	
	
	func _to_string():
		var result = "\n"
		var maze = self.spaceship()
		for y in range(maze.size()):
			maze[y].append(null)
		maze.append([])
		for x in range(maze[0].size()):
			maze[-1].append(null)
		for y in range(maze.size()):
			var lines = ["", ""]
			for x in range(maze[y].size()):
				if maze[y][x] != null or (x > 0 and maze[y][x-1] != null) or (y>0 and maze[y-1][x] != null) or (x>0 and y>0 and maze[y-1][x-1] != null):
					lines[0] += "+"
				else:
					lines[0] += " "
				if maze[y][x] != null or (y > 0 and maze[y-1][x] != null):
					var cell = maze[y][x]
					var dir = LayoutDirection.North
					if cell == null:
						cell = maze[y-1][x]
						dir = LayoutDirection.South
					match cell.doors[dir]:
						LayoutDoor.Normal:
							lines[0] += " "
						LayoutDoor.Broken:
							lines[0] += "x"
						LayoutDoor.Wall:
							lines[0] += "-"
				else:
					lines[0] += " "
				if maze[y][x] != null or (x > 0 and maze[y][x-1] != null):
					var cell = maze[y][x]
					var dir = LayoutDirection.West
					if cell == null:
						cell = maze[y][x-1]
						dir = LayoutDirection.East
					match cell.doors[dir]:
						LayoutDoor.Normal:
							lines[1] += " "
						LayoutDoor.Broken:
							lines[1] += "x"
						LayoutDoor.Wall:
							lines[1] += "|"
				else:
					lines[1] += " "
				if maze[y][x] != null:
					if maze[y][x].mission != null:
						lines[1] += maze[y][x].mission.type[0]
					else:
						if maze[y][x].get_neighbors(self).size() > 0:
							lines[1] += "*"
						else:
							lines[1] += "/"
				else:
					lines[1] += " "
			if y > 0:
				result += "\n"
			result += lines[0] + "\n" + lines[1]
		return result
		

class LayoutChromosome extends RefCounted:
	var _graph
	var _start_type
	var _end_type
	var _broken_type
	var _genome
	var _random
	var _fitness
	var _layout
	var _spaceship
	var _start
	
	
	func _init(graph, size, start_type, end_type, broken_type, random=null):
		self._graph = graph
		self._start_type = start_type
		self._end_type = end_type
		self._broken_type = broken_type
		if random == null:
			random = RandomNumberGenerator.new()
		self._random = random
		
		self._genome = []
		for i in range(size):
			self._genome.append(self._random.randi_range(0, LayoutDirection.values().size()-1))
		self._layout = null
		self._spaceship = null
		self._start = null
		self._fitness = -1.0
		
	
	func clone(graph):
		var clone = LayoutChromosome.new(self._graph, self._genome.size(), self._start_type, 
			self._end_type, self._broken_type, self._random)
		for i in range(self._genome.size()):
			clone._genome[i] = self._genome[i]
		return clone
		
	
	func mutate(graph, size=1):
		var clone = self.clone(graph)
		for i in range(size):
			var index = self._random.randi_range(0, self._genome.size()-1)
			var new_value = self._random.randi_range(0, LayoutDirection.values().size() - 1)
			clone._genome[index] = new_value
		return clone
		
	
	func crossover(other):
		var clone = self.clone(self._graph)
		var index = self._random.randi_range(0, self._genome.size()-1)
		for i in range(index, self._genome.size()):
			clone._genome[i] = other._genome[i]
		return clone
		
	
	func fitness():
		if self._layout == null:
			self._fitness = 0.0
			var layout_result = LayoutGenerator._mission_to_layout(self._graph, 
				self._genome, self._start_type, self._end_type, self._broken_type)
			self._layout = layout_result["layout"]
			self._fitness += 1.0 / (layout_result["placement"].size() + layout_result["missing"].size() + layout_result["connections"].size() + 1)
			var spaceship_result = LayoutGenerator._spaceship_2d(self._layout, self._start_type, self._broken_type, self._end_type)
			self._spaceship = spaceship_result["layout"]
			self._start = spaceship_result["start_loc"][0]
			if self._fitness == 1:
				self._fitness += 1.0 / spaceship_result["start"].size()
			if self._fitness == 2:
				self._fitness += 1.0 / (spaceship_result["connections"].size() + 1)
			if self._fitness == 3:
				self._fitness += 1.0 / (spaceship_result["end_connections"])
			if self._fitness == 4:
				self._fitness += 1.0 / max(1, self._spaceship.size() - 9)
			if self._fitness == 5:
				self._fitness += 1.0 / (abs(spaceship_result["broken"].size() - spaceship_result["extra"].size()) + 1)
				self._fitness += 2.0 / (spaceship_result["extra"].size() + 1)
				self._fitness += 0.05 * min(20, self._spaceship[0].size())
			#self._fitness += 1.0 / (layout_result["extra"] + 1)
			#self._fitness /= 3.0
		return self._fitness
		
	
	func spaceship_layout():
		if self._spaceship == null:
			self.fitness()
		return self._spaceship
		
	
	func _to_string():
		if self._layout == null:
			self.fitness()
		return str({"layout": self._layout, "fitness": self._fitness})
	

class LayoutGA extends RefCounted:
	var _graphs
	var _start_type
	var _end_type
	var _broken_type
	var _random
	var _population
	var _genome_size
	
	func _init(graphs, size, start_type, end_type, broken_type, random=null):
		self._graphs = graphs
		self._start_type = start_type
		self._end_type = end_type
		self._broken_type = broken_type
		if random == null:
			random = RandomNumberGenerator.new()
		self._random = random
		self._genome_size = 0
		for g in graphs:
			if g.nodes.size() > self._genome_size:
				self._genome_size = g.nodes.size()
		self.reset(size)
		
	
	func reset(size=-1):
		if size < 0:
			size = self._population.size()
		self._population = []
		for i in range(size):
			var graph = self._graphs[self._random.randi() % self._graphs.size()]
			self._population.append(LayoutChromosome.new(graph, self._genome_size, self._start_type, self._end_type, self._broken_type, self._random))
		
	
	func _select(size=7):
		var tournment = []
		for i in range(size):
			tournment.append(self._population[self._random.randi_range(0, self._population.size()-1)])
		tournment.sort_custom(func(a, b): return a.fitness() < b.fitness())
		return tournment[-1]
		
	
	func update(crossover_rate=0.5, mutation_rate=0.25, mutation_size=0.3, elitism=0.1, tournment=7):
		var size = self._population.size()
		self._population.sort_custom(func(a,b): return a.fitness() < b.fitness())
		var new_pop = []
		for i in range(max(1, floor(elitism * size))):
			new_pop.append(self._population[-1-i])
		while new_pop.size() < size:
			var parent = self._select(tournment)
			if self._random.randf() < crossover_rate:
				var parent2 = self._select(tournment)
				parent = parent.crossover(parent2)
			var graph = parent._graph
			if self._random.randf() < mutation_rate:
				graph = self._graphs[self._random.randi_range(0, self._graphs.size()-1)]
			var temp = self._random.randi_range(1, max(1, floor(mutation_size*graph.nodes.size())))
			new_pop.append(parent.mutate(graph, temp))
		
	
	func best():
		self._population.sort_custom(func(a,b): return a.fitness() < b.fitness())
		return self._population[-1]
		
