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
			
			frames = FlxImageFrame.fromFrame(_imageInfo.data); // change frames type
			
			aspectRatio = _imageInfo.width / _imageInfo.height;
			
			_imageWidth = frameWidth = _imageInfo.width;
			_imageHeight = frameHeight = _imageInfo.height;
		}
	}
	
	function validatePosition():Void { }
	
	function validateDisplay():Void {
		// imageClipRect
		// will need a bit of work, merging with parent clip
		// ugh
	}
}