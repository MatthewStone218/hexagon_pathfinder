// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
function hexagon_map(w,h,h_repeat,v_repeat){
	return new __class_hexagon_map__(w,h,h_repeat,v_repeat);
}

function __class_hexagon_map__(w,h,h_repeat,v_repeat) constructor {
	start_x = 0;
	start_y = 0;
	goal_x = 0;
	goal_y = 0,
	shader = shd_pathfind_basic;
	
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
	
	surface_set_target(map_surf);
	draw_clear(c_black);
	surface_reset_target();
	
	map_surf_buffer = buffer_create(1,buffer_grow,1);
	buffer_get_surface(map_surf_buffer,map_surf,0);
	
	get_map_x = function(xx){
		return xx;
	}
	
	get_map_y = function(xx,yy){
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
	
	set_map_value = function(xx,yy,val){
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
	
	set_indexed_map_value = function(xx,yy,val){
		indexed_map[xx][yy] = val;
	}
	
	reset_map_pathfind_surf = function(){
		if(!surface_exists(map_surf)){
			buffer_set_surface(map_surf_buffer,map_surf,0);
		}
		surface_copy(map_pathfind_surf,0,0,map_surf);
	}
	
	buffer_get_map_surf = function(){
		buffer_get_surface(map_surf_buffer,map_surf,0);
	}
	
	pathfind = function(_start_x,_start_y,_goal_x,_goal_y,_shader = shd_pathfind_basic){
		reset_map_pathfind_surf();
		ready_pathfind(_start_x,_start_y,_goal_x,_goal_y,true,_shader = shd_pathfind_basic);
		var _result;
		
		do{
			_result = step_pathfind(false);
		} until(_result[$"status"] != PATHFIND_STATUS.FINDING_PATH)
		
		end_pathfind();
		
		return _result;
	}
	
	step_pathfind = function(reset_shader = true,_shader = shd_pathfind_basic){
		if(!surface_exists(map_pathfind_surf)){
			reset_map_pathfind_surf();
		}
		if(reset_shader){
			shader_set(shader);
		}
		
		
		
		if(reset_shader){
			shader_reset();
		}
	}
	
	ready_pathfind = function(_start_x,_start_y,_goal_x,_goal_y,set_shader = false,_shader = shd_pathfind_basic){
		start_x = _start_x;
		start_y = _start_y;
		goal_x = _goal_x;
		goal_y = _goal_y;
		shader = _shader;
		if(set_shader){
			shader_set(shd_pathfind_basic);
		}
	}
	
	end_pathfind = function(){
		shader_reset();
	}
}

enum PATHFIND_STATUS{
	NO_PATH,
	FOUND_PATH,
	FINDING_PATH
}