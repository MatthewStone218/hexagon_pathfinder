/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다
global.map = hexagon_map(20,20,false,false);

for(var i = 0; i < global.map._.width; i++){
	for(var ii = 0; ii < global.map._.height; ii++){
		var _inst = instance_create_depth(i*180,ii*140 + ((i mod 2) == 1 ? 70 : 0),0,obj_hexagon_tile);
		_inst.map_indexed_x = i;
		_inst.map_indexed_y = ii;
		_inst.map_x = global.map._.get_map_surf_x(i);
		_inst.map_y = global.map._.get_map_surf_y(i,ii);
		global.map._.set_map_value(i,ii[0],_inst);
		global.map._.set_map_value(i,ii[1],_inst);
	}
}