//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel;
uniform float u_horizontal_repeat;
uniform float u_certical_repeat;

float move_point = 0.0;

bool consume_move_point(){
	if(move_point <= 0.01960784313){// 5/255
		move_point = 0.0;
		return true;
	} else {
		move_point -= 0.03921568627;// 10/255
		return false;
	}
}

bool check_red(xx,yy){
	if(xx < 0.0){
		if(!horizontal_repeat){
			return false;
		}
		xx = 1.0-u_texel.x;
	} else if(xx > 1.0){
		if(!horizontal_repeat){
			return false;
		}
		xx = u_texel.x;
	}
	if(yy < 0.0){
		if(!vertical_repeat){
			return false;
		}
		yy = 1.0-u_texel.y;
	} else if(yy > 1.0){
		if(!horizontal_repeat){
			return false;
		}
		yy = u_texel.y;
	}
	return texture2D( gm_BaseTexture, vec2(xx,yy) ).r == 1.0;
}

void main()
{
	vec4 base_color = texture2D( gm_BaseTexture, v_vTexcoord );
	move_point = base_color.g;
	
	//already calculated
	if(base_color.r == 1.0){
		gl_FragColor = vec4(1.0,0.0,base_color.b,1.0);
		return;
	}
	
	//check calculation + consume move point
	if(base_color.r > 0.6 && base_color.r < 0.9){
		if(consume_move_point()){
			gl_FragColor = vec4(1.0,0.0,base_color.b,1.0);
			return;
		}
		gl_FragColor = vec4(0.7,move_point,base_color.b,1.0);
		return;
	}
	
	bool is_upper_pixel = mod(floor(gl_FragCoord.x) + floor(gl_FragCoord.y),2.0) < 0.5;
	
	if(is_upper_pixel){
		//lt
	    if(v_vTexcoord.x-u_texel.x >= 0.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x-u_texel.x,v_vTexcoord.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.0392,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.0392,1.0);
			return;
		}
		//t
	    if(v_vTexcoord.y-u_texel.y >= 0.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x,v_vTexcoord.y-u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.1176,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.1176,1.0);
			return;
		}
		//rt
	    if(v_vTexcoord.x+u_texel.x <= 1.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x+u_texel.x,v_vTexcoord.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.1961,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.1961,1.0);
			return;
		}
		//lb
	    if(v_vTexcoord.x-u_texel.x >= 0.0 && v_vTexcoord.y+u_texel.y <= 1.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x-u_texel.x,v_vTexcoord.y+u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.2745,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.2745,1.0);
			return;
		}
		//b
	    if(v_vTexcoord.y+u_texel.y <= 1.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x,v_vTexcoord.y+u_texel.y+u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.3529,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.3529,1.0);
			return;
		}
		//rb
	    if(v_vTexcoord.x+u_texel.x <= 1.0 && v_vTexcoord.y+u_texel.y <= 1.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x+u_texel.x,v_vTexcoord.y+u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.4314,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.4314,1.0);
			return;
		}
	} else {
		//lt
	    if(v_vTexcoord.x-u_texel.x >= 0.0 && v_vTexcoord.y-u_texel.y >= 0.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x-u_texel.x,v_vTexcoord.y-u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.0392,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.0392,1.0);
			return;
		}
		//t
	    if(v_vTexcoord.y-u_texel.y >= 0.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x,v_vTexcoord.y-u_texel.y-u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.1176,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.1176,1.0);
			return;
		}
		//rt
	    if(v_vTexcoord.x+u_texel.x <= 1.0 && v_vTexcoord.y-u_texel.y >= 0.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x+u_texel.x,v_vTexcoord.y-u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.1961,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.1961,1.0);
			return;
		}
		//lb
	    if(v_vTexcoord.x-u_texel.x >= 0.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x-u_texel.x,v_vTexcoord.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.2745,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.2745,1.0);
			return;
		}
		//b
	    if(v_vTexcoord.y+u_texel.y <= 1.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x,v_vTexcoord.y+u_texel.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.3529,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.3529,1.0);
			return;
		}
		//rb
	    if(v_vTexcoord.x+u_texel.x <= 1.0 && texture2D( gm_BaseTexture, vec2(v_vTexcoord.x+u_texel.x,v_vTexcoord.y) ).r == 1.0){
			//consume move point
			if(consume_move_point()){
				gl_FragColor = vec4(1.0,0.0,0.4314,1.0);
				return;
			}
			gl_FragColor = vec4(0.7,move_point,0.4314,1.0);
			return;
		}
	}
	
	gl_FragColor = base_color;
}
