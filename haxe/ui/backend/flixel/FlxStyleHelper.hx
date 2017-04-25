package haxe.ui.backend.flixel;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
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
		
		if (style.backgroundImage != null) {
			Toolkit.assets.getImage(style.backgroundImage, function(ii:ImageInfo) {
				if (ii != null && ii.data != null) drawBG(sprite, ii.data, style);
			});
		}
		
		// border
	}
	
	static function drawBG(sprite:FlxSprite, data:ImageData, style:Style):Void {
		
		var bmd = data.parent.bitmap;
		var rect = bmd.rect;
		
		// 9slice
		
		if (style.backgroundImageClipTop != null && style.backgroundImageClipBottom != null && style.backgroundImageClipLeft != null && style.backgroundImageClipRight != null) {
			rect = new Rectangle(style.backgroundImageClipLeft, style.backgroundImageClipTop, style.backgroundImageClipRight - style.backgroundImageClipLeft, style.backgroundImageClipBottom - style.backgroundImageClipTop);
		}
		
		var matrix:Matrix = null;
		
		if (style.backgroundImageRepeat == "stretch") {
			matrix = new Matrix();
			matrix.scale(sprite.frameWidth / rect.width, sprite.frameHeight / rect.height);
		}
		
		if (matrix == null) {
			
			var blitPt = new Point();
			
			if (style.backgroundImageRepeat == null) {
				sprite.pixels.copyPixels(bmd, rect, blitPt);
			}
			
			else if (style.backgroundImageRepeat == "repeat") {
				
				var repX = Math.ceil(sprite.frameWidth / rect.width);
				var repY = Math.ceil(sprite.frameHeight / rect.height);
				
				for (i in 0...repX) {
					
					blitPt.x = i * rect.width;
					
					for (j in 0...repY) {
						
						blitPt.y = j * rect.height;
						
						sprite.pixels.copyPixels(bmd, rect, blitPt);
					}
				}
			}
		}
		
		else {
			sprite.pixels.draw(bmd, matrix, null, null, rect == bmd.rect ? null : rect);
		}
	}
}