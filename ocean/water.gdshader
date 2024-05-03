shader_type spatial;

// uniforms for fragmenet shader
uniform vec3 albedo: source_color;
uniform vec3 fresnel_base_color: source_color;

uniform float metallic: hint_range(0, 1) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform sampler2D texture_normal; 
uniform sampler2D texture_normal2;

uniform vec2 wave_direction = vec2(2, 0);
uniform vec2 wave_direction2 = vec2(0, 2);

uniform float ripple_time_scale : hint_range(0, 0.2, 0.005) = 0.025;
uniform float wave_time_scale : hint_range(0, 0.2, 0.005) = 0.025;

// uniforms for vertex shader
uniform sampler2D wave_normals;

uniform float noise_scale = 10;
uniform float height_scale = 0.15;

varying float height;
varying vec3 world_pos;

float fresnel(float amount, vec3 normal, vec3 view) {
	normal = normalize(normal);
	view = normalize(view);
	return pow(1.0 - clamp(dot(normal, view), 0, 1), amount);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave_normals, world_pos.xz / noise_scale + TIME * wave_time_scale).r;
	//height = sin(world_pos.xz / noise_scale + TIME * wave_time_scale).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	
	vec2 offset = (TIME * wave_direction) * ripple_time_scale;
	vec2 offset2 = (TIME * wave_direction2) * ripple_time_scale;
	
	vec2 pos = world_pos.xz * 1e-2;
	vec3 normal = mix(
		texture(texture_normal, pos + offset).rgb, 
		texture(texture_normal2, pos + offset2).rgb, 
		0.5
	);
	
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_colour = mix(albedo, fresnel_base_color, fresnel);
	
	ALBEDO = surface_colour;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal;
}
