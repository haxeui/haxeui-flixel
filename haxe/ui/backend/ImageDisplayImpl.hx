package haxe.ui.backend;

import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxRect;
import haxe.ui.Toolkit;

class ImageDisplayImpl extends ImageBase {
    public function new() {
        super();
        this.pixelPerfectRender = true;
        this.active = false;
    }
    
    private override function validateData():Void {
        if (_imageInfo != null) {
            frames = FlxImageFrame.fromFrame(_imageInfo.data);
            
            aspectRatio = _imageInfo.width / _imageInfo.height;

            origin.set(0, 0);
        }
    }
    
    private override function validateDisplay() {
        var scaleX:Float = _imageWidth / (_imageInfo.width / Toolkit.scaleX);
        var scaleY:Float = _imageHeight / (_imageInfo.height / Toolkit.scaleY);
        scale.set(scaleX, scaleY);

        width = Math.abs(scaleX) * frameWidth;
        height = Math.abs(scaleY) * frameHeight;
    }

    override function set_clipRect(rect:FlxRect):FlxRect {
        if (rect != null) {
            return super.set_clipRect(FlxRect.get(rect.x / scale.x, rect.y / scale.y, rect.width / scale.x, rect.height / scale.y));
        } else {
            return super.set_clipRect(null);
        }
    }
}
