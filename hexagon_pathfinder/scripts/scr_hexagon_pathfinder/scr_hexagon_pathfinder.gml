// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조

global.hexagon_maps = [];

function hexagon_map(w,h,h_repeat,v_repeat){
	var _map_struct = new __class_hexagon_map__(w,h,h_repeat,v_repeat);
	_map_struct.index = array_length(global.hexagon_maps);
	global.hexagon_maps[_map_struct.index] = { _: _map_struct };
	return global.hexagon_maps[_map_struct.index];
}

function __class_hexagon_map__(w,h,h_repeat,v_repeat) constructor {
	start_x = 0;
	start_y = 0;
	goal_x = 0;
	goal_y = 0;
	goal_cost = 10;
	
	shader = shd_pathfind_basic;
	static cmp_shader_under_texture_uniform_id = shader_get_uniform(shd_cmp,"u_underTexture");
	static pathfind_shader_texel_uniform_id = shader_get_uniform(shd_pathfind_basic,"u_texel");
	static pathfind_shader_horizontal_repeat_uniform_id = shader_get_uniform(shd_pathfind_basic,"u_horizontal_repeat");
	static pathfind_shader_vertical_repeat_uniform_id = shader_get_uniform(shd_pathfind_basic,"u_vertical_repeat");
	
	width = w;
	height = h;
	horizontal_repeat = h_repeat;
	vertical_repeat = v_repeat;
	
	if(horizontal_repeat && ((width mod 2) == 1)){
		show_error("Width of map must be even when it horizontal repeated!",true);
	}
	
	indexed_map = [];
	map = [];
	
	for(var i = 0; i < width; i++){
		for(var ii = 0; ii < height; ii++){
			indexed_map[i][ii] = -1;
		}
	}
	
	for(var i = 0; i < width; i++){
		for(var ii = 0; ii < height*2 + (width >= 2); ii++){
			map[i][ii] = -1;
		}
	}
	
	map_surf = surface_create(array_length(map),array_length(map[0]));
	map_pathfind_surf = surface_create(array_length(map),array_length(map[0]));
	original_surf_cmp = surface_create(array_length(map),array_length(map[0]) + ((array_length(map[0]) mod 2) == 1));
	
	clear_surface(map_surf,c_black);
	clear_surface(map_pathfind_surf,c_black);
	clear_surface(original_surf_cmp,c_black);
	
	surf_cmp = [];
	var _w = width;
	var _h = height*2 + (_w >= 2);
	_w = log2(_w);
	_h = log2(_h);
	_w = ceil(_w);
	_h = ceil(_h);
	_w = power(2,_w);
	_h = power(2,_h);
	
	do{
		var _surf = surface_create(_w,_h);
		clear_surface(_surf,c_black);
		array_push(surf_cmp,_surf);
		_w *= 0.5;
		_h *= 0.5;
		_w = max(_w,1);
		_h = max(_h,1);
	} until(_w <= 1 && _h <= 1)
	
	map_surf_buffer = buffer_create(1,buffer_grow,1);
	buffer_get_surface(map_surf_buffer,map_surf,0);
	
	static get_map_x = function(xx){
		return xx;
	}
	
	static get_map_y = function(xx,yy){
		var _upper_coord = yy*2 + (xx mod 2);
		var _lower_coord = _upper_coord+1;
		
		if(vertical_repeat){
			_upper_coord = _upper_coord mod (height*2 + (width >= 2));
			_lower_coord = _lower_coord mod (height*2 + (width >= 2));
		} else {
			_upper_coord = median(_upper_coord,0,(height*2 + (width >= 2))-1);
			_lower_coord = median(_lower_coord,0,(height*2 + (width >= 2))-1);
		}
		
		return [_upper_coord,_lower_coord];
	}
	
	static get_indexed_x_from_surf_coord = function(xx){
		return get_repeated_index(xx,width);
	}
	
	static get_indexed_y_from_surf_coord = function(xx,yy){
		yy = get_repeated_index(yy,height);
		var _index_y = floor(yy/2) - (xx mod 2);
		if(_index_y < 0){
			if(vertical_repeat){
				return height-1;
			} else {
				return 0;
			}
		}
		return _index_y;
	}
	
	static get_repeated_index = function(_idx,length){
		if(_idx < 0){
			return length-_idx;
		}
		if(_idx >= length){
			return length-_idx;
		}
		return _idx;
	}
	
	static set_map_value = function(xx,yy,val){
		var _upper_coord = yy*2 + ((xx mod 2) == 1);
		var _lower_coord = _upper_coord+1;
		if(_upper_coord+1 >= height*2 + (width >= 2) - 1){
			if(vertical_repeat){
				_lower_coord = 0;
			} else {
				_lower_coord = -1;
			}
		}
		map[xx][_upper_coord] = val;
		if(_lower_coord >= 0){ map[xx][_lower_coord] = val; }
	}
	
	static set_indexed_map_value = function(xx,yy,val){
		indexed_map[xx][yy] = val;
	}
	
	static reset_map_pathfind_surf = function(){
		if(!surface_exists(map_surf)){
			buffer_set_surface(map_surf_buffer,map_surf,0);
		}
		surface_copy(map_pathfind_surf,0,0,map_surf);
	}
	
	static buffer_get_map_surf = function(){
		buffer_get_surface(map_surf_buffer,map_surf,0);
	}
	
	static pathfind = function(_start_x,_start_y,_goal_x,_goal_y,_shader = shd_pathfind_basic){
		reset_map_pathfind_surf();
		ready_pathfind(_start_x,_start_y,_goal_x,_goal_y,_shader = shd_pathfind_basic);
		var _result;
		
		do{
			_result = step_pathfind();
			show_message(_result)
		} until(_result[$"status"] != PATHFIND_STATUS.FINDING_PATH)
		
		return _result;
	}
	
	static step_pathfind = function(){
		if(start_x == goal_x && start_y == goal_y){
			return {
				status: PATHFIND_STATUS.FOUND_PATH,
				path_tiles: [goal_x,goal_y],
			};
		}
		
		if(!surface_exists(map_pathfind_surf)){
			reset_map_pathfind_surf();
		}

		if(!surface_exists(original_surf_cmp)){
			surface_create(original_surf_cmp,array_length(map),array_length(map[0]));
		}
		
		surface_copy(original_surf_cmp,0,0,map_pathfind_surf);
		surface_set_target(map_pathfind_surf);
		
		shader_set(shader);
		shader_set_uniform_f(pathfind_shader_texel_uniform_id,texture_get_texel_width(surface_get_texture(map_pathfind_surf)),texture_get_texel_height(surface_get_texture(map_pathfind_surf)));
		shader_set_uniform_i(pathfind_shader_horizontal_repeat_uniform_id,horizontal_repeat);
		shader_set_uniform_i(pathfind_shader_vertical_repeat_uniform_id,vertical_repeat);
		
		draw_surface(original_surf_cmp,0,0);
		
		surface_reset_target();
		shader_reset();
		
		var _start_point_status_color = color_get_red(surface_getpixel(map_pathfind_surf,get_map_x(start_x),get_map_y(start_x,start_y)[0]));
		if(_start_point_status_color == 255){
			var _path_tiles = [[start_x,start_y]];
			
			var _buff = buffer_create(width*height*4,buffer_fixed,1);
			buffer_get_surface(_buff,map_pathfind_surf,0);

			var _x_index = start_x;
			var _y_index = start_y;
			
			while(_x_index != goal_x || _y_index != goal_y){
				var _x = get_map_x(_x_index);
				var _y = get_map_y(_x_index,_y_index)[0];
				var _vertical_odd = _x_index mod 2;
				var _dir = buffer_peek(_buff, (_y*width+_x)*4 + 2, buffer_u8);
				
				if(abs(_dir-10) < 0.1){
					_x_index = _x_index-1;
					_y_index = _vertical_odd ? _y_index : _y_index-1;
				} else if(abs(_dir-30) < 0.1){
					_y_index = _y_index-1;
				} else if(abs(_dir-50) < 0.1){
					_x_index = _x_index+1;
					_y_index = _vertical_odd ? _y_index : _y_index-1;
				} else if(abs(_dir-70) < 0.1){
					_x_index = _x_index-1;
					_y_index = _vertical_odd ? _y_index : _y_index+1;
				} else if(abs(_dir-90) < 0.1){
					_y_index = _y_index+1;
				} else if(abs(_dir-110) < 0.1){
					_x_index = _x_index+1;
					_y_index = _vertical_odd ? _y_index+1 : _y_index;
				} else {
					buffer_delete(_buff);
					return {
						status: PATHFIND_STATUS.FOUND_PATH_BUT_NO_DIR,
					};
				}
				array_push(_path_tiles,[_x_index,_y_index]);
				show_message($"{_dir}\n\n{_path_tiles}")
			}

			buffer_delete(_buff);
			
			return {
				status: PATHFIND_STATUS.FOUND_PATH,
				path_tiles: _path_tiles,
			};
		} else if(_start_point_status_color > 255*0.1 && _start_point_status_color < 255*0.4){
			return {
				status: PATHFIND_STATUS.STUCK_ON_WALL,
			}
		}
		
		
		if(!surface_exists(surf_cmp[0])){
			surface_create(surf_cmp[0],array_length(map),array_length(map[0]));
		}
		surface_set_target(surf_cmp[0]);
		draw_clear(c_black);
		
		shader_set(shd_cmp)
		texture_set_stage(cmp_shader_under_texture_uniform_id,surface_get_texture(original_surf_cmp));
		
		draw_surface(map_pathfind_surf,0,0);
		
		shader_reset();
		
		shader_set(shd_down_scale);
		for(var i = array_length(surf_cmp)-1; i > 0; i--){
			if(!surface_exists(surf_cmp[i-1])){
				surface_create(surf_cmp[i-1],power(2,i-1),power(2,i-1));
			}
			surface_reset_target();
			surface_set_target(surf_cmp[i-1]);
			draw_clear(c_black);
			draw_surface(surf_cmp[i],0,0);
		}
		shader_reset();
		
		surface_reset_target();
		surface_set_target(surf_cmp[0]);
		var _start_point_color = draw_getpixel(0,0);
		surface_reset_target();
		if(_start_point_color == #FFFFFF){
			return {
				status: PATHFIND_STATUS.NO_PATH,
			};
		}
		
		return {
			status: PATHFIND_STATUS.FINDING_PATH,
		};
	}
	
	static ready_pathfind = function(_start_x,_start_y,_goal_x,_goal_y,goal_cost = -1,_shader = shd_pathfind_basic){
		start_x = _start_x;
		start_y = _start_y;
		goal_x = _goal_x;
		goal_y = _goal_y;
		shader = _shader;
		if(goal_cost != -1){
			set_surf_goal_cost(goal_cost);
		}
	}
	
	static set_surf_goal_cost = function(goal_cost){
		reset_map_pathfind_surf();
		surface_set_target(map_pathfind_surf);
		draw_sprite_ext(spr_dot_1_1,0,goal_x,goal_y,1,2,0,make_color_rgb(255,goal_cost,0),1);
		surface_reset_target();
	}
	
	static clear_surface = function(surface,color,reset_target = false){
		var _surf_original = surface_get_target();
		surface_set_target(surface);
		draw_clear(color);
		surface_reset_target();
		if(!reset_target && _surf_original != -1){
			surface_set_target(_surf_original);
		}
	}
	
	static destroy = function(){
		surface_free(map_surf);
		surface_free(map_pathfind_surf);
		surface_free(surf_cmp);
		surface_free(original_surf_cmp);
		global.hexagon_maps[index]._ = undefined;
	}
}

enum PATHFIND_STATUS{
	FOUND_PATH,
	FINDING_PATH,
	STUCK_ON_WALL,
	NO_PATH,
	FOUND_PATH_BUT_NO_DIR,
}