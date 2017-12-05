package haxe.ui.backend;

import flixel.FlxSprite;
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
			
			frame = _imageInfo.data;
			aspectRatio = _imageInfo.width / _imageInfo.height;
			
			_imageWidth = frameWidth;
			_imageHeight = frameHeight;
		}
	}
	
	function validatePosition():Void { }
	
	function validateDisplay():Void {
		
		// scale?
		
		if (_imageClipRect == null) clipRect = null;
		else FlxRect.get(_imageClipRect.left, _imageClipRect.top, _imageClipRect.width, _imageClipRect.height);
	}
}