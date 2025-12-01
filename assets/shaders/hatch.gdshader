shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled;

uniform sampler2D cross_hatch_texture: filter_linear_mipmap_anisotropic;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;


uniform float uv_scale_r : hint_range(0.0, 60.0, 1.0) = 0.0;
uniform float uv_scale_g : hint_range(0.0, 60.0, 1.0) = 0.0;
uniform float uv_scale_b : hint_range(0.0, 60.0, 1.0) = 0.0;
uniform float hatch_uv_scale : hint_range(1.0, 60.0, 1.0) = 20.0;

uniform float smoothness : hint_range(0.02, 1.0, 0.01) = 0.02;
uniform float light_threshold : hint_range(0.0, 1.0, 0.01) = 0.9;
uniform float mid_threshold : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float dark_threshold : hint_range(0.0, 1.0, 0.01) = 0.3;

uniform float rim_amount : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float rim_smoothness : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float rim_strength : hint_range(1.0, 10.0, 0.1) = 1.0;
uniform vec4 rim_color : source_color;

uniform float specular_glossiness : hint_range(1.0, 100.0, 0.1) = 15.0;
uniform float specular_threshold : hint_range(0.01, 1.0, 0.001) = 0.5;
uniform float specular_softness : hint_range(0.0, 1.0, 0.001) = 0.1;

uniform sampler2D shadow_gradient : source_color;
uniform vec4 shadow_color : source_color;
//uniform sampler2D fresnel_gradient;

uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

//float fresnel(float amount, vec3 normal, vec3 view)
//{
	//return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
//}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 base_uv = UV;
	//float basic_fresnel = fresnel(4.0, NORMAL, VIEW);
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	//ALBEDO = albedo.rgb * albedo_tex.rgb + (basic_fresnel * texture(fresnel_gradient, vec2(basic_fresnel, 0.0)).rgb * 1.0);

	ALBEDO = albedo.rgb * albedo_tex.rgb;
}



void light() {
	float diffuse_value = (dot(LIGHT, NORMAL) * ATTENUATION) + wrap;
	diffuse_value *= steepness;
	float light_value = 0.5;

	float edge2 = light_threshold - smoothness;
	float mid_edge2 = mid_threshold - smoothness;
	float dark_edge2 = dark_threshold - smoothness;

	vec2 hatch_uv_r = UV * (hatch_uv_scale + uv_scale_r);
	vec2 hatch_uv_g = UV * (hatch_uv_scale + uv_scale_g);
	vec2 hatch_uv_b = UV * (hatch_uv_scale + uv_scale_b);

	float dotproduct = clamp(dot(NORMAL, LIGHT), -0.9, 0.9) + wrap;
	float sample = clamp((dotproduct + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 ramp_sample = texture(shadow_gradient, vec2(sample, 0.0));

	light_value -= smoothstep(light_threshold, edge2, sample) * texture(cross_hatch_texture, hatch_uv_r).r;
	light_value -= smoothstep(mid_threshold, mid_edge2, sample) * texture(cross_hatch_texture, hatch_uv_g).g;
	light_value -= smoothstep(dark_threshold, dark_edge2, sample) * texture(cross_hatch_texture, hatch_uv_b).b;


	// Diffuse light
	DIFFUSE_LIGHT +=  (light_value) * clamp((ramp_sample.rgb * LIGHT_COLOR), 0.005, 1.5) ;

	//Specular


	// Rim light
	float rim_light = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	float rim_edge2 = rim_amount + rim_smoothness;
	rim_light = smoothstep(rim_amount, rim_edge2, rim_light);
	DIFFUSE_LIGHT += rim_light * rim_color.rgb * rim_strength;

}
