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

bool pathfind(bool is_upper_pixel, bool is_odd_horizontally){
	if(is_upper_pixel){
		if(is_odd_horizontally){
			//t
			if(check_red(v_vTexcoord.x,v_vTexcoord.y-u_texel.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.1176,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.1176,1.0);
				return true;
			}
			
			//lt
			if(check_red(v_vTexcoord.x-u_texel.x,v_vTexcoord.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.0392,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.0392,1.0);
				return true;
			}
			//rt
			if(check_red(v_vTexcoord.x+u_texel.x,v_vTexcoord.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.1961,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.1961,1.0);
				return true;
			}
		} else {
			//b
			if(check_red(v_vTexcoord.x,v_vTexcoord.y+u_texel.y+u_texel.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.3529,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.3529,1.0);
				return true;
			}
			//lb
			if(check_red(v_vTexcoord.x-u_texel.x,v_vTexcoord.y+u_texel.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.2745,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.2745,1.0);
				return true;
			}
			//rb
			if(check_red(v_vTexcoord.x+u_texel.x,v_vTexcoord.y+u_texel.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.4314,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.4314,1.0);
				return true;
			}
		}
	} else {
		if(is_odd_horizontally){
			//t
			if(check_red(v_vTexcoord.x,v_vTexcoord.y-u_texel.y-u_texel.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.1176,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.1176,1.0);
				return true;
			}
			if(is_odd_verticaly){
				//lt
				if(check_red(v_vTexcoord.x-u_texel.x,v_vTexcoord.y-u_texel.y)){
					//consume move point
					if(consume_move_point()){
						gl_FragColor = vec4(1.0,0.0,0.0392,1.0);
						return true;
					}
					gl_FragColor = vec4(0.7,move_point,0.0392,1.0);
					return true;
				}
				//rt
				if(check_red(v_vTexcoord.x+u_texel.x,v_vTexcoord.y-u_texel.y)){
					//consume move point
					if(consume_move_point()){
						gl_FragColor = vec4(1.0,0.0,0.1961,1.0);
						return true;
					}
					gl_FragColor = vec4(0.7,move_point,0.1961,1.0);
					return true;
				}
			}
		} else {
			//lb
			if(check_red(v_vTexcoord.x-u_texel.x,v_vTexcoord.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.2745,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.2745,1.0);
				return true;
			}
			//b
			if(check_red(v_vTexcoord.x,v_vTexcoord.y+u_texel.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.3529,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.3529,1.0);
				return true;
			}
			//rb
			if(check_red(v_vTexcoord.x+u_texel.x,v_vTexcoord.y)){
				//consume move point
				if(consume_move_point()){
					gl_FragColor = vec4(1.0,0.0,0.4314,1.0);
					return true;
				}
				gl_FragColor = vec4(0.7,move_point,0.4314,1.0);
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
