package haxe.ui.backend;

import flixel.graphics.FlxGraphic;
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
}
