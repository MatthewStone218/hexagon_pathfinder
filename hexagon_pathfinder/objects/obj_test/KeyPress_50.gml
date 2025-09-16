/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다
var _result = global.map._.step_pathfind();
if(_result[$"status"] == PATHFIND_STATUS.FOUND_PATH){
	show_message("found path!")
}