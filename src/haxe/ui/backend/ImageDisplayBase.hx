package haxe.ui.backend;

import flixel.FlxSprite;
import haxe.ui.assets.ImageInfo;

class ImageDisplayBase extends FlxSprite {
	
    public var aspectRatio:Float = 1; // width x height

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

    public var imageWidth(get, set):Float;
    private function set_imageWidth(value:Float):Float {
        //frameWidth = Std.int(value);
        return value;
    }

    private function get_imageWidth():Float {
        return frameWidth;
    }

    public var imageHeight(get, set):Float;
    private function set_imageHeight(value:Float):Float {
        //frameHeight = Std.int(value);
        return value;
    }

    private function get_imageHeight():Float {
        return frameHeight;
    }

    private var _imageInfo:ImageInfo;
    public var imageInfo(get, set):ImageInfo;
    private function get_imageInfo():ImageInfo {
        return _imageInfo;
    }
    private function set_imageInfo(value:ImageInfo):ImageInfo {
        
		_imageInfo = value;
        aspectRatio = value.width / value.height;
		
		loadGraphic(value.data);
		
        return value;
    }

    public function dispose():Void {
        // destroy();
    }
}