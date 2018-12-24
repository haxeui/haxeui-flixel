package haxe.ui.backend;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.utils.ByteArray;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxImageFrame;
import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;
import haxe.ui.util.ByteConverter;
import openfl.Assets;
import openfl.utils.AssetType;

class AssetsBase {

	var frames(get, never):FlxFramesCollection;
	
	function get_frames():FlxFramesCollection {
		if (Toolkit.assets.options != null && Toolkit.assets.options.spritesheet != null) return Toolkit.assets.options.spritesheet;
		return null;
	}
	
	public function new() {
		
	}
	
	function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
		
		var graphic:FlxGraphic = null;
		var frame:FlxFrame = null;
		
		if (Assets.exists(resourceId)) {
			graphic = FlxGraphic.fromAssetKey(resourceId);
		}
		
		if (graphic == null) {
			var fr = frames;
			if (fr != null && fr.framesHash.exists(resourceId)) frame = fr.getByName(resourceId);
		}
		
		else {
			frame = FlxImageFrame.fromGraphic(graphic).frame;
		}
		
		if (frame != null) {
			frame.parent.persist = true;
			frame.parent.destroyOnNoUse = false;
			callback( { data : frame, width : Std.int(frame.sourceSize.x), height : Std.int(frame.sourceSize.y) } );
		}
		
		else callback(null);
	}

	function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void):Void {
		var bytes = Resource.getBytes(resourceId);
        trace("resourceId: " + resourceId);
		imageFromBytes(bytes, callback.bind(resourceId));
	}
	
	public function imageFromBytes(bytes:Bytes, callback:ImageInfo->Void):Void {
		
		var ba:ByteArray = ByteConverter.fromHaxeBytes(bytes);
		
		var loader:Loader = new Loader();
		
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e) {
			
			if (loader.content != null) {
				var frame = FlxImageFrame.fromImage(cast(loader.content, Bitmap).bitmapData).frame;
				frame.parent.persist = true; // these two booleans will screw up the UI unless changed from the default values
				frame.parent.destroyOnNoUse = false;
				callback( { data : frame, width : Std.int(frame.sourceSize.x), height : Std.int(frame.sourceSize.y) } );
			}
		});
		
		loader.loadBytes(ba);
	}

	function getFontInternal(resourceId:String, callback:FontInfo->Void):Void {
		
		var fontName:String = null;
		
		if (isEmbeddedFont(resourceId) && Assets.exists(resourceId, AssetType.FONT)) {
			fontName = Assets.getFont(resourceId).fontName;
		}
		
		else {
			fontName = resourceId;
		}
		
		callback( { data : fontName } );
	}

	function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void):Void {
		callback(resourceId, null);
	}

	function getTextDelegate(resourceId:String):String {
		
		if (Assets.exists(resourceId)) {
			return Assets.getText(resourceId);
		}
		
		return null;
	}
	
	static inline function isEmbeddedFont(fontName:String):Bool {
		return fontName != "_sans" && fontName != "_serif" && fontName != "_typewriter";
	}
}
