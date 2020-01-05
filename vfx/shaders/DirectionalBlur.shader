shader_type canvas_item;
render_mode blend_mix;

uniform float angle_degrees;
uniform float strength : hint_range(0,1, 0.0001);

//	Directional Blur Shader

vec4 dirBlur(sampler2D sampler, vec2 uv, vec2 dir) {
	int samples = 50;
	vec4 l = vec4(0);
	float delta = 1.0 / float(samples);
	for(float i = -1.0; i <= 1.0; i += delta)
    {
        l += texture(sampler, uv - vec2(dir.x * i, dir.y * i)).rgba;
    }
	return vec4(l*delta*0.5);
}


void fragment(){
	vec2 blur_vector = vec2(cos(radians(angle_degrees)),sin(radians(angle_degrees)))*strength;
	COLOR=dirBlur(TEXTURE, UV, blur_vector);
}