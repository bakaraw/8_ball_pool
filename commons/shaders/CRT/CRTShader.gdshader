shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float pixel_size : hint_range(1.0, 16.0) = 1.5;
uniform float scanline_intensity : hint_range(0.0, 0.5) = 0.3;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float color_depth : hint_range(2.0, 32.0) = 16.0;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.15;
uniform float glow_spread : hint_range(1.0, 8.0) = 2.0;

void fragment() {
    vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 uv = floor(SCREEN_UV * screen_size / pixel_size) * pixel_size / screen_size;
    vec4 color = texture(SCREEN_TEXTURE, uv);
    
    // color quantization
    color.rgb = floor(color.rgb * color_depth) / color_depth;
    
    // glow
    vec4 glow = vec4(0.0);
    float total = 0.0;
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) * glow_spread / screen_size;
            vec4 sample_color = texture(SCREEN_TEXTURE, SCREEN_UV + offset);  // renamed from sample
            float weight = 1.0 / (1.0 + float(x*x + y*y));
            glow += sample_color * weight;
            total += weight;
        }
    }
    glow /= total;
    
    float brightness = dot(glow.rgb, vec3(0.2126, 0.7152, 0.0722));
    color.rgb += glow.rgb * brightness * glow_strength;
    
    // scanlines
    float scanline = sin(SCREEN_UV.y * screen_size.y * 3.14159) * scanline_intensity;
    color.rgb -= scanline;
    
    // vignette
    vec2 vig_uv = SCREEN_UV * (1.0 - SCREEN_UV.yx);
    float vignette = pow(vig_uv.x * vig_uv.y * 15.0, vignette_intensity);
    color.rgb *= vignette;
    
    COLOR = color;
}