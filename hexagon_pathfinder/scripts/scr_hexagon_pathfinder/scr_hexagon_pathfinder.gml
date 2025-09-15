// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조

global.hexagon_maps = [];

function hexagon_map(w,h,h_repeat,v_repeat){
	var _map_struct = new __class_hexagon_map__(w,h,h_repeat,v_repeat);
	_map_struct.index = array_length(global.hexagon_maps);
	global.hexagon_maps[_map_struct.index] = { _: _map_struct };
}

function __class_hexagon_map__(w,h,h_repeat,v_repeat) constructor {
	start_x = 0;
	start_y = 0;
	goal_x = 0;
	goal_y = 0;
	
	shader = shd_pathfind_basic;
	static cmp_shader_under_texture_uniform_id = shader_get_uniform(shd_cmp,"u_underTexture");
	static pathfind_shader_texel_uniform_id = shader_get_uniform(shd_pathfind_basic,"u_texel");
	
	width = w;
	height = h;
	horizon_repeat = h_repeat;
	vertical_repeat = v_repeat;
	
	if(horizon_repeat && ((width mod 2) == 1)){
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
	original_surf_cmp = surface_create(array_length(map),array_length(map[0]));
	
	surf_cmp = [];
	var _w = width + (width != 1 && (width mod 2) == 1);
	var _h = height + (height != 1 && (height mod 2) == 1);
	
	do{
		array_push(surf_cmp,surface_create(_w,_h));
		_w *= 0.5;
		_h *= 0.5;
		_w = max(_w,1);
		_h = max(_h,1);
	} until(_w <= 1 && _h <= 1)
	
	surface_set_target(map_surf);
	draw_clear(c_black);
	surface_reset_target();
	
	map_surf_buffer = buffer_create(1,buffer_grow,1);
	buffer_get_surface(map_surf_buffer,map_surf,0);
	
	static get_map_x = function(xx){
		return xx;
	}
	
	static get_map_y = function(xx,yy){
		var _upper_coord = yy*2 + ((xx mod 2) == 1);
		var _lower_coord = _upper_coord+1;
		if(_upper_coord+1 >= height*2 + (width >= 2) - 1){
			if(vertical_repeat){
				_lower_coord = 0;
			} else {
				_lower_coord = -1;
			}
		}
		
		return [_upper_coord,_lower_coord];
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
		} until(_result[$"status"] != PATHFIND_STATUS.FINDING_PATH)
		
		return _result;
	}
	
	static step_pathfind = function(_shader = shd_pathfind_basic){
		if(!surface_exists(map_pathfind_surf)){
			reset_map_pathfind_surf();
		}
		shader_set(shader);
		shader_set_uniform_f(pathfind_shader_texel_uniform_id,texture_get_texel_width(surface_get_texture(map_pathfind_surf)),texture_get_texel_height(surface_get_texture(map_pathfind_surf)));

		if(!surface_exists(original_surf_cmp)){
			surface_create(original_surf_cmp,array_length(map),array_length(map[0]));
		}
		
		surface_copy(original_surf_cmp,0,0,map_pathfind_surf);
		surface_set_target(map_pathfind_surf);
		
		draw_surface(map_pathfind_surf,0,0);
		
		surface_reset_target();
		shader_reset();
		
		var _start_point_status_color = color_get_red(draw_getpixel(start_x,start_y));
		if(_start_point_status_color == 1){
			return;
		} else if(_start_point_status_color > 0.1 && _start_point_status_color < 0.4){
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
		texture_set_stage(cmp_shader_under_texture_uniform_id,surface_get_texture(original_surf_cmp))
		
		draw_surface(map_pathfind_surf,0,0);
		
		shader_reset();
		surface_reset_target();
		
		shader_set(shd_down_scale);
		for(var i = array_length(surf_cmp)-1; i > 0; i++){
			if(!surface_exists(surf_cmp[i-1])){
				surface_create(surf_cmp[i-1],power(2,i-1),power(2,i-1));
			}
			surface_set_target(surf_cmp[i-1]);
			draw_clear(c_black);
			draw_surface(surf_cmp[i],0,0);
		}
		shader_reset();
		
		surface_set_target(surf_cmp[0]);	
		if(draw_getpixel(0,0) == #FFFFFF){
			return {
				status: PATHFIND_STATUS.NO_PATH,
			}
		}
		
		return {
			status: PATHFIND_STATUS.FINDING_PATH,
		}
	}
	
	static ready_pathfind = function(_start_x,_start_y,_goal_x,_goal_y,_shader = shd_pathfind_basic){
		start_x = _start_x;
		start_y = _start_y;
		goal_x = _goal_x;
		goal_y = _goal_y;
		shader = _shader;
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
}