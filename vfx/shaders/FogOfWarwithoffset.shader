shader_type canvas_item;

uniform float intensity : hint_range(0.1,2.0);
uniform sampler2D noise_texture : hint_albedo;
uniform vec2 offset;

void fragment() {
	vec2 coord = SCREEN_UV + offset;
	
	vec4 noise1 = texture(noise_texture, coord * TIME * 0.012);
	vec4 noise2 = texture(noise_texture, vec2(coord.y, coord.x) - TIME * 0.012);
	
	vec4 final = mix(noise1,noise2,0.5);
	
	if (final.a > 0.0) {
		final.a = final.r * intensity;
	}
	
	COLOR = final;
}