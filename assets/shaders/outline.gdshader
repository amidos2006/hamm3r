shader_type spatial;
render_mode cull_front, unshaded, depth_draw_never;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}