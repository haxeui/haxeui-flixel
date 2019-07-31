package haxe.ui.backend;

import flixel.graphics.frames.FlxImageFrame;

class ImageDisplayImpl extends ImageBase {
	public function new() {
		super();
	}

	override public function destroy():Void {
		super.destroy();
		
		parentComponent = null;
		_imageInfo = null; // destroy?
		_imageClipRect = null;
	}
	
	override function validateData():Void {
		
		if (_imageInfo != null) {
			
			// in case the graphic came from a spritesheet
			var atlasFrames = _imageInfo.data.parent.getFramesCollections(flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType.ATLAS);
			
			if (atlasFrames.length > 0) {
				frames = atlasFrames[0];
				frame = _imageInfo.data;
			}
			
			else {
				frames = FlxImageFrame.fromFrame(_imageInfo.data);
			}
			
			aspectRatio = _imageInfo.width / _imageInfo.height;
			
			width = frameWidth = _imageInfo.width;
			height = frameHeight = _imageInfo.height;
		}
	}
	
	override function validatePosition():Void { }
	
	override function validateDisplay():Void {
		
		// imageClipRect
		
	}
}