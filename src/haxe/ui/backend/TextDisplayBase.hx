package haxe.ui.backend;

import flixel.text.FlxText;
import openfl.Assets;
import openfl.text.TextFormat;

class TextDisplayBase extends FlxText {

    public function new() {
        super();

    }

    public var left(get, set):Float;
    private function get_left():Float {
        return this.x;
    }
    private function set_left(value:Float):Float {
        this.x = value;
        return value;
    }

    public var top(get, set):Float;
    private function get_top():Float {
        return this.y;
    }
    private function set_top(value:Float):Float {
        this.y = value;
        return value;
    }

    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        var v = this.textField.textWidth;
        return v;
    }

    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
        var v = this.textField.textHeight;
        return v;
    }

    public var fontName(get, set):String;
    private function get_fontName():String {
        return textField.getTextFormat().font;
    }
    private function set_fontName(value:String):String {
        textField.embedFonts = isEmbeddedFont(value);
        var format:TextFormat = textField.getTextFormat();
        if (isEmbeddedFont(value)) {
            format.font = Assets.getFont(value).fontName;
        } else {
            format.font = value;
        }
        textField.defaultTextFormat = format;
        textField.setTextFormat(format);
        return value;
    }

    public var fontSize(get, set):Null<Float>;
    private function get_fontSize():Null<Float> {
        return textField.getTextFormat().size;
    }
    private function set_fontSize(value:Null<Float>):Null<Float> {
        var format:TextFormat = textField.getTextFormat();
        format.size = Std.int(value);
        textField.defaultTextFormat = format;
        textField.setTextFormat(format);
        return value;
    }

    private static inline function isEmbeddedFont(name:String):Bool {
        return (name != "_sans" && name != "_serif" && name != "_typewriter");
    }
}