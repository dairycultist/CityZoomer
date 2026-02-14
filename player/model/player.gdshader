shader_type spatial;

uniform sampler2D albedo : source_color;
uniform sampler2D color_map;
uniform sampler2D first_person_mask;

uniform vec3 color : source_color = vec3(1.0, 0.5, 0.0);

void fragment() {
	
	if (texture(first_person_mask, UV).r < 0.5) {
		discard;
	}
	
	ALBEDO = texture(albedo, UV).rgb * mix(vec3(1.), color, texture(color_map, UV).r);
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
