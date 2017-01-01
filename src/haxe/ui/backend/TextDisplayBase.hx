package haxe.ui.backend;

import flixel.text.FlxText;
import haxe.ui.core.Component;

class TextDisplayBase extends FlxText {
    public var parent:Component;
    
    public function new() {
        super();
    }

    public var left(get, set):Float;
    private function get_left():Float {
        return x;
    }
    private function set_left(value:Float):Float {
        x = parent.screenLeft + value;
        return value;
    }

    public var top(get, set):Float;
    private function get_top():Float {
        return y;
    }
    private function set_top(value:Float):Float {
        y = parent.screenTop + value;
        return value;
    }

    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        var v = textField.textWidth + 4;
        return v;
    }

    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
        var v = textField.textHeight + 4;
        return v;
    }

    public var fontName(get, set):String;
    private function get_fontName():String {
        return embedded ? font : systemFont;
    }
    private function set_fontName(value:String):String {
		
        var emb = isEmbeddedFont(value);
		
        if (emb) {
            font = value;
        } else {
            systemFont = value;
        }
		
        return value;
    }

    public var fontSize(get, set):Null<Float>;
    private function get_fontSize():Null<Float> {
        return size;
    }
    private function set_fontSize(value:Null<Float>):Null<Float> {
        return size = Std.int(value);
    }

    private static inline function isEmbeddedFont(name:String):Bool {
        return (name != "_sans" && name != "_serif" && name != "_typewriter");
    }
    
    private var _textAlign:String;
    public var textAlign(get, set):String;
    private function get_textAlign():String {
        return _textAlign;
    }
    private function set_textAlign(value:String):String {
        _textAlign = value;
        return value;
    }
}