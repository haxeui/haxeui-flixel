package haxe.ui.backend;

import flixel.graphics.frames.FlxImageFrame;

class ImageDisplayImpl extends ImageBase {
    public function new() {
        super();
        this.pixelPerfectRender = true;
    }
    
    private override function validateData():Void {
        if (_imageInfo != null) {
            frames = FlxImageFrame.fromFrame(_imageInfo.data);
            
			aspectRatio = _imageInfo.width / _imageInfo.height;
            
            width = frameWidth = _imageInfo.width;
            height = frameHeight = _imageInfo.height;
        }
    }
    
    private override function validateDisplay() {
        var scaleX:Float = _imageWidth / _imageInfo.width;
        var scaleY:Float = _imageHeight / _imageInfo.height;
        origin.set(0, 0);
        scale.set(scaleX, scaleY);
    }
}
