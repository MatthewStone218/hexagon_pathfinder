//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel;
uniform bool u_horizontal_repeat;
uniform bool u_vertical_repeat;

float move_point = 0.0;

bool consume_move_point(){
	if(move_point <= 0.01960784313){// 5/255
		move_point = 0.0;
		return true;
	} else {
		move_point -= 0.07843137254;// 20/255
		return false;
	}
}

bool check_red(float xx,float yy){
	if(xx < 0.0){
		if(!u_horizontal_repeat){
			return false;
		}
		xx = 1.0-u_texel.x;
	} else if(xx > 1.0){
		if(!u_horizontal_repeat){
			return false;
		}
		xx = u_texel.x;
	}
	if(yy < 0.0){
		if(!u_vertical_repeat){
			return false;
		}
		yy = 1.0-u_texel.y;
	} else if(yy > 1.0){
		if(!u_vertical_repeat){
			return false;
		}
		yy = u_texel.y;
	}
	return texture2D( gm_BaseTexture, vec2(xx,yy) ).r == 1.0;
}

bool calculate_tile_t(float balance){
	if(check_red(v_vTexcoord.x,v_vTexcoord.y-u_texel.y + balance*u_texel.y)){
		//consume move point
		if(consume_move_point()){
			gl_FragColor = vec4(1.0,0.0,0.1176,1.0);
			return true;
		}
		gl_FragColor = vec4(0.7,move_point,0.1176,1.0);
		return true;
	}
	return false;
}

bool calculate_tile_b(float balance){
	if(check_red(v_vTexcoord.x,v_vTexcoord.y+u_texel.y + balance*u_texel.y)){
		//consume move point
		if(consume_move_point()){
			gl_FragColor = vec4(1.0,0.0,0.3529,1.0);
			return true;
		}
		gl_FragColor = vec4(0.7,move_point,0.3529,1.0);
		return true;
	}
	return false;
}

bool calculate_tile_lt(float balance){
	if(check_red(v_vTexcoord.x-u_texel.x,v_vTexcoord.y + balance*u_texel.y)){
		//consume move point
		if(consume_move_point()){
			gl_FragColor = vec4(1.0,0.0,0.0392,1.0);
			return true;
		}
		gl_FragColor = vec4(0.7,move_point,0.0392,1.0);
		return true;
	}
	return false;
}

bool calculate_tile_lb(float balance){
	if(check_red(v_vTexcoord.x-u_texel.x,v_vTexcoord.y + balance*u_texel.y)){
		//consume move point
		if(consume_move_point()){
			gl_FragColor = vec4(1.0,0.0,0.2745,1.0);
			return true;
		}
		gl_FragColor = vec4(0.7,move_point,0.2745,1.0);
		return true;
	}
	return false;
}

bool calculate_tile_rt(float balance){
	if(check_red(v_vTexcoord.x+u_texel.x,v_vTexcoord.y + balance*u_texel.y)){
		//consume move point
		if(consume_move_point()){
			gl_FragColor = vec4(1.0,0.0,0.1961,1.0);
			return true;
		}
		gl_FragColor = vec4(0.7,move_point,0.1961,1.0);
		return true;
	}
	return false;
}

bool calculate_tile_rb(float balance){
	if(check_red(v_vTexcoord.x+u_texel.x,v_vTexcoord.y + balance*u_texel.y)){
		//consume move point
		if(consume_move_point()){
			gl_FragColor = vec4(1.0,0.0,0.4314,1.0);
			return true;
		}
		gl_FragColor = vec4(0.7,move_point,0.4314,1.0);
		return true;
	}
	return false;
}

bool pathfind(bool is_upper_pixel, bool is_odd_horizontally){
	if(is_upper_pixel){
		if(is_odd_horizontally){
			//t
			if(calculate_tile_t(0.0)){
				return true;
			}
			//b
			if(calculate_tile_b(1.0)){
				return true;
			}
			//lb
			if(calculate_tile_lb(1.0)){
				return true;
			}
			//lt
			if(calculate_tile_lt(0.0)){
				return true;
			}
			//rt
			if(calculate_tile_rt(0.0)){
				return true;
			}
			//rb
			if(calculate_tile_rb(1.0)){
				return true;
			}
		} else {
			//t
			if(calculate_tile_t(0.0)){
				return true;
			}
			//b
			if(calculate_tile_b(1.0)){
				return true;
			}
			//rb
			if(calculate_tile_rb(1.0)){
				return true;
			}
			//rt
			if(calculate_tile_rt(0.0)){
				return true;
			}
			//lt
			if(calculate_tile_lt(0.0)){
				return true;
			}
			//lb
			if(calculate_tile_lb(1.0)){
				return true;
			}
		}
	} else {
		if(is_odd_horizontally){
			//t
			if(calculate_tile_t(-1.0)){
				return true;
			}
			//b
			if(calculate_tile_b(0.0)){
				return true;
			}
			//lb
			if(calculate_tile_lb(0.0)){
				return true;
			}
			//lt
			if(calculate_tile_lt(-1.0)){
				return true;
			}
			//rb
			if(calculate_tile_rb(0.0)){
				return true;
			}
			//rt
			if(calculate_tile_rt(-1.0)){
				return true;
			}
		} else {
			//t
			if(calculate_tile_t(-1.0)){
				return true;
			}
			//b
			if(calculate_tile_b(0.0)){
				return true;
			}
			//rb
			if(calculate_tile_rb(0.0)){
				return true;
			}
			//rt
			if(calculate_tile_rt(-1.0)){
				return true;
			}
			//lb
			if(calculate_tile_lb(0.0)){
				return true;
			}
			//lt
			if(calculate_tile_lt(-1.0)){
				return true;
			}
		}
	}
	
	return false;
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
	bool is_odd_horizontally = mod(floor(gl_FragCoord.x),2.0) > 0.5;
	
	if(pathfind(is_upper_pixel,is_odd_horizontally)){
		return;
	}
	if(pathfind(is_upper_pixel,!is_odd_horizontally)){
		return;
	}
	
	gl_FragColor = base_color;
}
