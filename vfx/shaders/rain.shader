shader_type canvas_item;

uniform sampler2D noise;
uniform float intensity = 0.02;

void fragment() {
    vec2 uv = vec2(SCREEN_UV);
    uv += (texture(noise, uv + vec2(TIME/10.0,TIME/1.0)).rb-vec2(.53))*intensity;
    COLOR = vec4(texture(SCREEN_TEXTURE, uv).rgb, 1.0);
}