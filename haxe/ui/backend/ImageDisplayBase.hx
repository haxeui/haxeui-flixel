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

	public var left:Float;
	public var top:Float;

	public var imageWidth(get, set):Float;
	inline function get_imageWidth():Float { return frameWidth; }
	inline function set_imageWidth(value:Float):Float {
		//frameWidth = Std.int(value);
		return value;
	}


	public var imageHeight(get, set):Float;
	inline function get_imageHeight():Float { return frameHeight; }
	inline function set_imageHeight(value:Float):Float {
		//frameHeight = Std.int(value);
		return value;
	}
	
	public var imageInfo(default, set):ImageInfo;
	function set_imageInfo(value:ImageInfo):ImageInfo {
		
		if (imageInfo != value) {
			
			// if (imageInfo != null) imageInfo.data.destroy();
			
			imageInfo = value;
			
			if (value != null) {
				aspectRatio = value.width / value.height;
				frame = value.data;
			}
		}
		
		return value;
	}
	
	public var imageClipRect(default, set):Rectangle;
	function set_imageClipRect(value:Rectangle):Rectangle {
		
		imageClipRect = value;
		
		if (value == null) clipRect = null;
		else clipRect = FlxRect.get(value.left, value.top, value.width, value.height);
		
		return value;
	}
	
	override public function destroy():Void {
		super.destroy();
		
		parent = null;
		imageInfo = null; // destroy?
		imageClipRect = null;
	}
	
	override public function draw():Void {
		
		if (dirty) {
			x = left + parent.screenLeft;
			y = top + parent.screenTop;
		}
		
		super.draw();
	}
}