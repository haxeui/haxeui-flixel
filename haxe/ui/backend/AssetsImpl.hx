package haxe.ui.backend;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxImageFrame;
import haxe.io.Bytes;
import haxe.ui.assets.FontInfo;
import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageData;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.utils.AssetType;
import openfl.utils.ByteArray;

class AssetsImpl extends AssetsBase {
    private override function getImageInternal(resourceId:String, callback:ImageInfo->Void):Void {
        var graphic:FlxGraphic = null;
        var frame:FlxFrame = null;
        
        if (Assets.exists(resourceId)) {
            graphic = FlxGraphic.fromAssetKey(resourceId);
            frame = FlxImageFrame.fromGraphic(graphic).frame;            
        }
        
        if (frame != null) {
            frame.parent.persist = true;
            frame.parent.destroyOnNoUse = false;
            callback({
                data : frame,
                width : Std.int(frame.sourceSize.x),
                height : Std.int(frame.sourceSize.y)
            });
        } else {
            callback(null);
        }
    }
    
    private override function getImageFromHaxeResource(resourceId:String, callback:String->ImageInfo->Void):Void {
        if (Resource.listNames().indexOf(resourceId) == -1) {
            callback(resourceId, null);
        } else {
            var bytes = Resource.getBytes(resourceId);
            imageFromBytes(bytes, callback.bind(resourceId));
        }
    }
    
    public override function imageFromBytes(bytes:Bytes, callback:ImageInfo->Void):Void {
        var ba:ByteArray = ByteArray.fromBytes(bytes);
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e) {
            if (loader.content != null) {
                var frame = FlxImageFrame.fromImage(cast(loader.content, Bitmap).bitmapData).frame;
                frame.parent.persist = true; // these two booleans will screw up the UI unless changed from the default values
                frame.parent.destroyOnNoUse = false;
                callback({
                    data : frame,
                    width : Std.int(frame.sourceSize.x),
                    height : Std.int(frame.sourceSize.y)
                });
            } else {
                callback(null);
            }
        });
        loader.contentLoaderInfo.addEventListener("ioError", function(e) {
            trace(e);
            callback(null);
        });
        
        loader.loadBytes(ba);
    }
    
    private override function getFontInternal(resourceId:String, callback:FontInfo->Void):Void {
        var fontName:String = null;
        if (isEmbeddedFont(resourceId) && Assets.exists(resourceId, AssetType.FONT)) {
            fontName = Assets.getFont(resourceId).fontName;
        } else {
            fontName = resourceId;
        }
        callback({
            data : fontName
        });
    }
    
    private override function getTextDelegate(resourceId:String):String {
        if (Assets.exists(resourceId)) {
            return Assets.getText(resourceId);
        }
        return null;
    }
    
    public override function imageInfoFromImageData(imageData:ImageData):ImageInfo {
        return {
            data: imageData,
            width: Std.int(imageData.frame.width),
            height: Std.int(imageData.frame.height)
        }
    }
    
    private static inline function isEmbeddedFont(fontName:String):Bool {
        return fontName != "_sans" && fontName != "_serif" && fontName != "_typewriter";
    }
}
