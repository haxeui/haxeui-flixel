package haxe.ui.backend;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Component;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class ImageDisplayBase extends FlxSpriteGroup { // maybe it should just extend sprite
    public var parentComponent:Component;
    public var aspectRatio:Float = 1; // width x height
	private var _sprite:FlxSprite;

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
        _sprite.frameWidth = Std.int(value);
        return value;
    }

    private function get_imageWidth():Float {
        if (_sprite == null) {
            return 0;
        }
        return _sprite.frameWidth;
    }

    public var imageHeight(get, set):Float;
    private function set_imageHeight(value:Float):Float {
        _sprite.frameHeight = Std.int(value);
        return value;
    }

    private function get_imageHeight():Float {
        if (_sprite == null) {
            return 0;
        }
        return _sprite.frameHeight;
    }

    private var _imageInfo:ImageInfo;
    public var imageInfo(get, set):ImageInfo;
    private function get_imageInfo():ImageInfo {
        return _imageInfo;
    }
    private function set_imageInfo(value:ImageInfo):ImageInfo {
        _imageInfo = value;
        aspectRatio = value.width / value.height;

        if (_sprite != null && members.indexOf(_sprite) > -1) {
            remove(_sprite, true);
            //_bmp.bitmapData.dispose();
        }

        _sprite = new FlxSprite(_imageInfo.data);
        add(_sprite);
        return value;
    }

    public function dispose():Void {
        if (_sprite != null) {
            //_bmp.bitmapData.dispose();
        }
    }
}