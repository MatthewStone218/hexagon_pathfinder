/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다
global.map = hexagon_map(20,20,false,false);

for(var i = 0; i < global.map.width; i++){
	for(var ii = 0; ii < global.map.height; ii++){
		var _inst = instance_create_depth(i*180,ii*70,0,obj_hexagon_tile);
		_inst.map_surf_x = global.map.get_map_surf_x(i);
		_inst.map_surf_y = global.map.get_map_surf_y(i,ii);
		global.map.set_value(i,ii,_inst);
	}
}