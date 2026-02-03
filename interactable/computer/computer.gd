extends StaticBody3D


enum ScreenType{
	FACE_3R,
	GUN,
	CABINET,
	NOISE,
	SPACESHIP
}


@export var moniter_1:ScreenType:
	set(value): 
		moniter_1 = value
		if self.is_node_ready() and $Pivot/Monitor1 != null:
			_assign_screen($Pivot/Monitor1, value)
@export var moniter_2:ScreenType:
	set(value): 
		moniter_2 = value
		if self.is_node_ready() and $Pivot/Monitor2 != null:
			_assign_screen($Pivot/Monitor2, value)
@export var moniter_3:ScreenType:
	set(value):
		moniter_3 = value
		if self.is_node_ready() and $Pivot/Monitor3 != null:
			_assign_screen($Pivot/Monitor3, value)
@export var moniter_4:ScreenType:
	set(value): 
		moniter_4 = value
		if self.is_node_ready() and $Pivot != null and $Pivot/Monitor4 != null:
			_assign_screen($Pivot/Monitor4, value)


var _texture_3R = [preload("res://assets/graphics/screens/CntrlRoom_Computers_CntrlRoom_Screen_Desk_3R.png")]
var _texture_gun = [preload("res://assets/graphics/screens/CntrlRoom_Screen_L.png")]
var _texture_cabinet = [preload("res://assets/graphics/screens/CntrlRoom_Screen_M.png")]
var _texture_noise = [preload("res://assets/graphics/screens/CntrlRoom_Screen_Desk_f1.png"), preload("res://assets/graphics/screens/CntrlRoom_Screen_Desk_f2.png"), preload("res://assets/graphics/screens/CntrlRoom_Screen_Desk_f3.png")]
@onready var _texture_spaceship = [$SpaceshipMap.get_texture()]


func _assign_screen(screen, type):
	var texture = null
	if type == ScreenType.FACE_3R:
		texture = _texture_3R.pick_random()
	elif type == ScreenType.GUN:
		texture = _texture_gun.pick_random()
	elif type == ScreenType.CABINET:
		texture = _texture_cabinet.pick_random()
	elif type == ScreenType.NOISE:
		texture = _texture_noise.pick_random()
	elif type == ScreenType.SPACESHIP:
		texture = _texture_spaceship.pick_random()
	screen.get_surface_override_material(1).set_shader_parameter("albedo_texture", texture)

func _ready():
	$AnimationPlayer.play("Idle")


func show_gun():
	$AnimationPlayer.play("Gun_Show")
	
	
func setup_ship(spaceship_cells, start_cell, start_direction):
	$SpaceshipMap/TileMapLayer.clear()
	var cells = []
	for y in spaceship_cells.size():
		for x in spaceship_cells[y].size():
			if spaceship_cells[y][x] != null:
				cells.append(Vector2(x, y))
	$SpaceshipMap/TileMapLayer.set_cells_terrain_connect(cells, 0, 0)
	var tile_size = Vector2($SpaceshipMap/TileMapLayer.tile_set.tile_size)
	var ship_size = Vector2(spaceship_cells[0].size() * tile_size.x, 
		spaceship_cells.size() * tile_size.y)
	$SpaceshipMap/TileMapLayer/Arrow.position = start_cell * tile_size + tile_size/2
	$SpaceshipMap/TileMapLayer.position = (Vector2($SpaceshipMap.size) - ship_size) / 2 - Vector2(0, 60)
	$SpaceshipMap/NinePatchRect.position = (Vector2($SpaceshipMap.size) - ship_size) / 2 - Vector2(0, 60) - 2 * tile_size
	$SpaceshipMap/NinePatchRect.size = ship_size + 4 * tile_size
	
	match start_direction:
		LayoutGenerator.LayoutDirection.North:
			$SpaceshipMap/TileMapLayer/Arrow.position += Vector2(0, -1.5 * tile_size.y)
			$SpaceshipMap/TileMapLayer/Arrow.rotation_degrees = 90
		LayoutGenerator.LayoutDirection.South:
			$SpaceshipMap/TileMapLayer/Arrow.position += Vector2(0, 1.5 * tile_size.y)
			$SpaceshipMap/TileMapLayer/Arrow.rotation_degrees = 270
		LayoutGenerator.LayoutDirection.East:
			$SpaceshipMap/TileMapLayer/Arrow.position += Vector2(1.5 * tile_size.x, 0)
			$SpaceshipMap/TileMapLayer/Arrow.rotation_degrees = 180
		LayoutGenerator.LayoutDirection.West:
			$SpaceshipMap/TileMapLayer/Arrow.position += Vector2(-1.5 * tile_size.x, 0)
			$SpaceshipMap/TileMapLayer/Arrow.rotation_degrees = 0
