shader_type canvas_item;

uniform  float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;
uniform vec2 number_of_tiles = vec2(16, 9);
uniform vec2 pixels_per_tile = vec2(16,16);

void fragment() {
	vec2 position_in_square = UV * number_of_tiles;
	vec2 pixel_position = round(position_in_square * pixels_per_tile);
	vec2 frac = fract(pixel_position / pixels_per_tile);
	vec2 direction = frac -0.5;
	if(abs(direction.x) + abs(direction.y) - UV.y + 1.0 >= progress*2.0){
		if(!reverse){
			discard;
		}
	}
	else if(reverse){
		discard;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
