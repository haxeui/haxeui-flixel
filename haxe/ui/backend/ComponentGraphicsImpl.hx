package haxe.ui.backend;

import haxe.io.Bytes;
import haxe.ui.core.Component;
import haxe.ui.util.Color;
import haxe.ui.util.ImageLoader;
import haxe.ui.util.Variant;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class ComponentGraphicsImpl extends ComponentGraphicsBase {
	private var _hasSize:Bool = false;
	private var sprite:FlxSprite;
	public function new(component:Component) {
		super(component);
	}

	private var bitmapData:BitmapData = null;

	public override function setPixels(pixels:Bytes) {
		if (_hasSize == false) {
			return super.setPixels(pixels);
		}
		var w = Std.int(_component.width);
		var h = Std.int(_component.height);

		if (bitmapData == null) {
			bitmapData = new BitmapData(Std.int(_component.width), Std.int(_component.height), true, 0x00000000);
		} else {
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
			bitmapData.setPixels(new Rectangle(_component.x, _component.y, bitmapData.width, bitmapData.height), byteArray);
		}

		if (this.sprite == null) {
			sprite = new FlxSprite(_component.x, _component.y);
			sprite.width = w;
			sprite.height = h;
			sprite.pixels = bitmapData;
			_component.add(sprite);
		}
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
