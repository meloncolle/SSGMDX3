shader_type canvas_item;
uniform float strength : hint_range(0, 1);
uniform float radius;
uniform vec3 color : source_color;

//const float outer_edge = SCREEN_UV;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float outer = smoothstep(0.5, 0.5 - (2.0 / radius), distance(UV, vec2(0.5)));
	//float inner = smoothstep(0.5 - (40.0 / radius), 0.5, distance(UV, vec2(0.5)));
	float inner = smoothstep(mix(0.5 - (40.0 / radius), 0.2, strength),
							 mix(0.5, 0.7, strength), 
							 distance(UV, vec2(0.5))) + mix(0.0, 0.5, strength)
							 - mix(0.5, 0.0, strength);
	//float pulse = smoothstep(0.5, 1.0, fract((distance(UV, vec2(0.5)) * 0.5) * 4.0 - (TIME * sqrt(strength)))) - mix(0.5, 0.0, strength);;
	//float mask = (inner + pulse) * outer;
	float mask = inner * outer;
	
	COLOR = vec4(color, mask);
}