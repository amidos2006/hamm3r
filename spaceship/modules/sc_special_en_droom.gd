extends Node3D


@export var shoot_computer:JSON
@export var rollspeed:float = 1.0
@export var swimspeed:float = 0.5


var code_screens = []
var organism_screens = []
var time = 0.0


var _shutdown_screen = preload("res://assets/models/ControlRoom_Computers_CntrlRoom_Screen_S_OFF.png")
var _cow_screen = preload("res://assets/textures/tex_spaceship/T_screen_sim.png")
var _micro_screen = preload("res://assets/textures/tex_spaceship/T_screen_sim_Small.png")
var _code_screen = preload("res://assets/textures/tex_spaceship/T_screen_text_scroll.png")

func _ready():
	code_screens.append($mod_EndRoom/mod_end_Screen_L3)
	code_screens.append($mod_EndRoom/mod_end_Screen_L2)
	code_screens.append($mod_EndRoom/mod_end_Screen_L1)
	code_screens.append($mod_EndRoom/mod_end_Screen_R3)
	code_screens.append($mod_EndRoom/mod_end_Screen_R2)
	code_screens.append($mod_EndRoom/mod_end_Screen_R1)
	
	for screen in code_screens:
		screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _code_screen)
		screen.get_surface_override_material(0).set_shader_parameter("texture_uv", Vector2(0.0, randf()))
		screen.get_surface_override_material(0).set_shader_parameter("roll", true)
		screen.get_surface_override_material(0).set_shader_parameter("roll_size", 15.0)
	
	organism_screens.append($mod_EndRoom/mod_end_Screen_R4)
	organism_screens.append($mod_EndRoom/mod_end_Screen_L4)
	
	for screen in organism_screens:
		screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _micro_screen)
		screen.get_surface_override_material(0).set_shader_parameter("texture_uv", Vector2(randf(), randf()))
		screen.get_surface_override_material(0).set_shader_parameter("roll", true)
		screen.get_surface_override_material(0).set_shader_parameter("roll_size", 15.0)
		
	var screen = $mod_EndRoom/mod_end_Screen_MID
	screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _cow_screen)
	screen.get_surface_override_material(0).set_shader_parameter("roll", true)
	screen.get_surface_override_material(0).set_shader_parameter("roll_size", 15.0)


func _process(delta):
	for screen in code_screens:
		var current = screen.get_surface_override_material(0).get_shader_parameter("texture_uv")
		current.y += delta * rollspeed
		screen.get_surface_override_material(0).set_shader_parameter("texture_uv", current)
	
	time += delta
	for screen in organism_screens:
		var current = screen.get_surface_override_material(0).get_shader_parameter("texture_uv")
		current.y = sin(time * swimspeed)
		current.x = cos(time * swimspeed / 2)
		screen.get_surface_override_material(0).set_shader_parameter("texture_uv", current)
	
	
func shutdown_computers():
	for screen in code_screens:
		screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _shutdown_screen)
		screen.get_surface_override_material(0).set_shader_parameter("roll", false)
		screen.get_surface_override_material(0).set_shader_parameter("roll_size", 0.0)
	for screen in organism_screens:
		screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _shutdown_screen)
		screen.get_surface_override_material(0).set_shader_parameter("roll", false)
		screen.get_surface_override_material(0).set_shader_parameter("roll_size", 0.0)
	var screen = $mod_EndRoom/mod_end_Screen_MID
	screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _shutdown_screen)
	screen.get_surface_override_material(0).set_shader_parameter("roll", false)
	screen.get_surface_override_material(0).set_shader_parameter("roll_size", 0.0)


func shoot_computers():
	for screen in code_screens:
		screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _shutdown_screen)
		screen.get_surface_override_material(0).set_shader_parameter("roll", false)
		screen.get_surface_override_material(0).set_shader_parameter("roll_size", 0.0)
	for screen in organism_screens:
		screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _shutdown_screen)
		screen.get_surface_override_material(0).set_shader_parameter("roll", false)
		screen.get_surface_override_material(0).set_shader_parameter("roll_size", 0.0)
	var screen = $mod_EndRoom/mod_end_Screen_MID
	screen.get_surface_override_material(0).set_shader_parameter("albedo_texture", _shutdown_screen)
	screen.get_surface_override_material(0).set_shader_parameter("roll", false)
	screen.get_surface_override_material(0).set_shader_parameter("roll_size", 0.0)
