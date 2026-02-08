shader_type spatial;

uniform sampler2D albedo : source_color;
uniform sampler2D color_map;

uniform vec3 color : source_color = vec3(1.0, 0.5, 0.0);

void fragment() {
	ALBEDO = texture(albedo, UV).rgb * mix(vec3(1.), color, texture(color_map, UV).r);
}
