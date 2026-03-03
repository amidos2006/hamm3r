shader_type canvas_item;

uniform sampler2D mask_texture;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    float mask = texture(mask_texture, UV).a;

    base.r *= mask;
	base.g *= mask;
	base.b *= mask;

    COLOR = base;
}