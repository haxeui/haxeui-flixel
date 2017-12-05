package haxe.ui.backend;

class TextInputBase extends TextDisplayBase {
	
	var _password:Bool;
	var _hscrollPos:Float;
	var _vscrollPos:Float;
	
	public function new() {
		super();
		
		_password = false;
		_hscrollPos = _vscrollPos = 0;
	}
}
