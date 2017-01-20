package haxe.ui.backend;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.utils.ByteArray;
import flixel.graphics.FlxGraphic;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;
import haxe.ui.util.ByteConverter;
import openfl.Assets;

class AssetsBase {

    public function new() {
		
    }

    function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
		
		if (!Assets.exists(resourceId)) {
			callback(null);
			return;
		}
		
		var graphic = FlxGraphic.fromAssetKey(resourceId);
		
		if (graphic != null) callback( { data : graphic, width : graphic.width, height : graphic.height } );
		else callback(null);
    }

    function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void) {
        
		var bytes = Resource.getBytes(resourceId);
        var ba:ByteArray = ByteConverter.fromHaxeBytes(bytes);
		
        var loader:Loader = new Loader();
		
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e) {
			
            if (loader.content != null) {
                var graphic = FlxGraphic.fromBitmapData(cast(loader.content, Bitmap).bitmapData);
                callback(resourceId, { data : graphic, width : graphic.width, height : graphic.height } );
            }
        });
		
        loader.loadBytes(ba);
    }

    function getFontInternal(resourceId:String, callback:FontInfo->Void):Void {
        callback(null);
    }

    function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void) {
        callback(resourceId, null);
    }

    function getTextDelegate(resourceId:String):String {
        
		if (Assets.exists(resourceId)) {
			return Assets.getText(resourceId);
		}
		
		return null;
    }
}
