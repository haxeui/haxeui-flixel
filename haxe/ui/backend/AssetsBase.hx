package haxe.ui.backend;

import flixel.graphics.FlxGraphic;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;

class AssetsBase {

    public function new() {

    }

    private function getFontInternal(resourceId:String, callback:FontInfo->Void):Void {
        callback(null);
    }

    private function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
		
		var graphic = FlxGraphic.fromAssetKey(resourceId);
		
		if (graphic != null) callback( { data : graphic, width : graphic.width, height : graphic.height } );
		else callback(null);
    }

    private function getFontFromHaxeResource(resourceId:String, callback:String->FontInfo->Void) {
        callback(resourceId, null);
    }

    private function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void) {
        callback(resourceId, null);
    }

    private function getTextDelegate(resourceId:String):String {
        return null;
    }
}
