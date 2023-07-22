package haxe.ui.backend;

import flixel.FlxSprite;
import haxe.io.Bytes;
import haxe.ui.core.Component;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

class ComponentGraphicsImpl extends ComponentGraphicsBase {
    private var _hasSize:Bool = false;
    private var bitmapData:BitmapData = null;
    private var sprite:FlxSprite;

    public override function setPixels(pixels:Bytes) {
        if (_hasSize == false) {
            return super.setPixels(pixels);
        }

        var w = Std.int(_component.width);
        var h = Std.int(_component.height);

        if (bitmapData == null) {
            bitmapData = new BitmapData(w, h, true, 0x00000000);
        }

        // convert RGBA -> ARGB (well, actually BGRA for some reason)
        var bytesData = pixels.getData();
        var length:Int = pixels.length;
        var newPixels = Bytes.alloc(length);
        var i:Int = 0;
        while (i < length) {
            var r = Bytes.fastGet(bytesData, i + 0);
            var g = Bytes.fastGet(bytesData, i + 1);
            var b = Bytes.fastGet(bytesData, i + 2);
            var a = Bytes.fastGet(bytesData, i + 3);
            newPixels.set(i + 0, b);
            newPixels.set(i + 1, g);
            newPixels.set(i + 2, r);
            newPixels.set(i + 3, a);
            i += 4;
        }
        var byteArray = ByteArray.fromBytes(newPixels);
        bitmapData.setPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height), byteArray);

        if (this.sprite == null) {
            sprite = new FlxSprite(0, 0);
            _component.add(sprite);            
        }

        sprite.width = w;
        sprite.height = h;

        this.sprite.pixels = bitmapData;
    }

    public override function resize(width:Null<Float>, height:Null<Float>) {
        if (width > 0 && height > 0) {
            if (_hasSize == false) {
                _hasSize = true;
                replayDrawCommands();
            }
        }
    }
}