shader_type canvas_item;

uniform sampler2D scene_tex;
uniform float power:hint_range(0.0, 1.0, 0.001) = 0.0;

vec2 noise(vec2 uv){
	uv = vec2(dot(uv, vec2(127.1, 311.7)), dot(uv, vec2(269.5, 183.3)));
	return fract(sin(uv) * 43758.5453123) - 0.5;
}

void fragment(){
	COLOR = texture(scene_tex, UV + noise(UV) * power);
}

//void fragment() {
	//float size = power * 100.0;
    //vec2 texel = size / vec2(textureSize(scene_tex, 0));
	//vec2 tex_size = vec2(textureSize(scene_tex, 0));
	//if(power < 0.001){
		//COLOR = texture(scene_tex, UV);
	//}
	//else{
		//vec2 pixel_uv = (floor(UV * tex_size / size) + 0.5) * size;
		//vec2 new_uv = pixel_uv / tex_size;
	    //COLOR = texture(scene_tex, new_uv);
	//}
//}

//void fragment() {
    //vec2 texel = 1.0 / vec2(textureSize(scene_tex, 0));
    //vec4 sum = vec4(0.0);
    //float count = 0.0;
	//if(power < 0.001){
		//COLOR = vec4(texture(scene_tex, UV).rgb, 1.0);
	//}
	//else{
	    //for (float x = -2.0; x <= 2.0; x++) {
	        //for (float y = -2.0; y <= 2.0; y++) {
				//if(pow(x, 2) + pow(y, 2) < 6.0){
		            //sum += texture(scene_tex, UV + vec2(x, y) * texel * power * 100.0);
		            //count += 1.0;
				//}
	        //}
	    //}
	    //COLOR = sum / count;
	//}
//}