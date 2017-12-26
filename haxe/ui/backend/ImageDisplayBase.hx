package haxe.ui.backend;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxRect;
import haxe.ui.assets.ImageInfo;
import haxe.ui.core.Component;
import haxe.ui.util.Rectangle;

class ImageDisplayBase extends FlxSprite {
	
	public var parent:Component;
	
	public var aspectRatio:Float = 1; // width x height

	public function new() {
		super();
	}

	var _left:Float;
	var _top:Float;

	var _imageWidth:Float;
	var _imageHeight:Float;
	
	var _imageInfo:ImageInfo;
	var _imageClipRect:Rectangle;
	
	override public function destroy():Void {
		super.destroy();
		
		parent = null;
		_imageInfo = null; // destroy?
		_imageClipRect = null;
	}
	
	function validateData():Void {
		
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
	
	function validatePosition():Void { }
	
	function validateDisplay():Void {
		
		// imageClipRect
		
	}
}