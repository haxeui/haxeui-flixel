package haxe.ui.backend;

import flixel.graphics.frames.FlxImageFrame;
import haxe.ui.Toolkit;

class ImageDisplayImpl extends ImageBase {
    public function new() {
        super();
        this.pixelPerfectRender = true;
    }
    
    private override function validateData():Void {
        if (_imageInfo != null) {
            frames = FlxImageFrame.fromFrame(_imageInfo.data);
            
            aspectRatio = _imageInfo.width / _imageInfo.height;
            
            width = frameWidth = Std.int(_imageInfo.width * Toolkit.scaleX);
            height = frameHeight = Std.int(_imageInfo.height *  Toolkit.scaleY);
        }
    }
    
    private override function validateDisplay() {
        var scaleX:Float = _imageWidth / (_imageInfo.width / Toolkit.scaleX);
        var scaleY:Float = _imageHeight / (_imageInfo.height / Toolkit.scaleY);
        origin.set(0, 0);
        scale.set(scaleX, scaleY);
    }
}
