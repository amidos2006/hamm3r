extends CompositorEffect
class_name BlurEffect

@export var power: float = 0.1

func _render_callback(effect_callback_type, render_data):
	var src = render_data.get_color_texture()
	var shader = Shader.new()
	shader.code = preload("res://interface/3d_camera_blur/materials/blur_shader.gdshader").code
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("scene_tex", src)
	mat.set_shader_parameter("power", power)
	render_data.blit_to_screen(mat)
