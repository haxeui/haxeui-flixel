package haxe.ui.backend;

class TextInputBase extends TextDisplayBase {
	
	public var hscrollPos:Float;
    public var vscrollPos:Float;
    public var multiline:Bool;
	
	public var password(get, set):Bool;
	inline function get_password():Bool { return textField.displayAsPassword; }
	inline function set_password(value:Bool):Bool { return textField.displayAsPassword = value; }
	
    public function new() {
        super();
    }
}
