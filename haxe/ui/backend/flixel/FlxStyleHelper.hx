package haxe.ui.backend.flixel;
import flash.display.BitmapData;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageData;
import haxe.ui.styles.Style;

/**
 * ...
 * @author MSGhero
 */
class FlxStyleHelper{
	
	public static function applyStyle(sprite:FlxSprite, style:Style):Void {
		
		if (sprite.pixels == null) return;
		
		var pixels = sprite.pixels;
		
		if (style.backgroundColor != null) {
			
			var opacity = style.backgroundOpacity == null ? 1 : style.backgroundOpacity;
			var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.backgroundColor;
			var radius:Float = style.borderRadius == null ? 0 : style.borderRadius;
			
			// gradient
			
			if (radius == 0) pixels.fillRect(sprite.pixels.rect, color);
			else FlxSpriteUtil.drawRoundRect(sprite, 0, 0, sprite.frameWidth, sprite.frameHeight, radius, radius, color);
		}
		
		// border
		
		if (style.backgroundImage != null) {
			Toolkit.assets.getImage(style.backgroundImage, function(ii:ImageInfo) {
				if (ii != null && ii.data != null) drawBG(sprite, ii.data, style);
			});
		}
	}
	
	static function drawBG(sprite:FlxSprite, data:ImageData, style:Style):Void {
		
		// clip
		
		// 9slice
		
		// else
	}
}