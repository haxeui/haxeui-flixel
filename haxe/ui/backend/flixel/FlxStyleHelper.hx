package haxe.ui.backend.flixel;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;
import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageData;
import haxe.ui.styles.Style;
import haxe.ui.geom.Slice9;

/**
 * ...
 * @author MSGhero
 */
class FlxStyleHelper {
	
	public static function applyStyle(sprite:FlxSprite, style:Style):Void {
		
		if (sprite.pixels == null) return;
		
		var pixels = sprite.pixels;
		
        
        
        
        
        var left:Float = 0;
        var top:Float = 0;
        var width:Float = sprite.frameWidth;
        var height:Float = sprite.frameHeight;
        
        if (width <= 0 || height <= 0) {
            return;
        }
        
        var rc:Rectangle = new Rectangle(top, left, width, height);
        var borderRadius:Float = 0;
        if (style.borderRadius != null) {
            borderRadius = style.borderRadius;
        }

        var lineStyle:LineStyle = FlxSpriteUtil.getDefaultLineStyle();
        lineStyle.thickness = 0;
        if (style.borderLeftSize != null && style.borderLeftSize != 0
            && style.borderLeftSize == style.borderRightSize
            && style.borderLeftSize == style.borderBottomSize
            && style.borderLeftSize == style.borderTopSize

            && style.borderLeftColor != null
            && style.borderLeftColor == style.borderRightColor
            && style.borderLeftColor == style.borderBottomColor
            && style.borderLeftColor == style.borderTopColor) { // TODO: kinda ugly border issue with pixel anti-aliasing (it seems) - only seems to be html5?
            lineStyle.thickness = style.borderLeftSize;
            lineStyle.color = style.borderLeftColor | 0xFF000000;
            rc.left += style.borderLeftSize / 2;
            rc.top += style.borderLeftSize / 2;
            rc.bottom -= style.borderLeftSize / 2;
            rc.right -= style.borderLeftSize / 2;
            //rc.inflate( -(style.borderLeftSize / 2), -(style.borderLeftSize / 2));
        }        
        
        if (rc.width <= 0 || rc.height <= 0) {
            return;
        }
         
        
        
        
        
        
        
        
        
        
        
		if (style.backgroundColor != null) {
			
			var opacity = style.backgroundOpacity == null ? 1 : style.backgroundOpacity;
			var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.backgroundColor;
			var radius:Float = style.borderRadius == null ? 0 : style.borderRadius + 2;
			
			// gradient
			
			if (radius == 0) {
                pixels.fillRect(rc, color);
            } else {
                //var drawStyle:DrawStyle = { smoothing: false };
                if (lineStyle.thickness > 0) {
                    FlxSpriteUtil.drawRoundRect(sprite, rc.left, rc.top, rc.width, rc.height, radius, radius, color, lineStyle);
                } else {
                    FlxSpriteUtil.drawRoundRect(sprite, rc.left, rc.top, rc.width, rc.height, radius, radius, color);
                }
            }
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
		var rect = data.frame.copyToFlash();
		
		// if it's a spritesheet and the frame is rotated or flipped, paint the "original" sprite
		if (!bmd.rect.equals(rect) && (data.angle != FlxFrameAngle.ANGLE_0 || data.flipX || data.flipY)) {
			bmd = data.paintRotatedAndFlipped();
			rect.setTo(0, 0, data.sourceSize.x, data.sourceSize.y);
		}
		
		if (style.backgroundImageClipTop != null && style.backgroundImageClipBottom != null && style.backgroundImageClipLeft != null && style.backgroundImageClipRight != null) {
			rect.x += style.backgroundImageClipLeft;
			rect.y += style.backgroundImageClipTop;
			rect.width = Math.min(rect.width, style.backgroundImageClipRight - style.backgroundImageClipLeft);
			rect.height = Math.min(rect.height, style.backgroundImageClipBottom - style.backgroundImageClipTop);
		}
		
		var slice:haxe.ui.geom.Rectangle = null;
		
		if (style.backgroundImageSliceTop != null && style.backgroundImageSliceBottom != null && style.backgroundImageSliceLeft != null && style.backgroundImageSliceRight != null) {
			slice = new haxe.ui.geom.Rectangle(style.backgroundImageSliceLeft, style.backgroundImageSliceTop, style.backgroundImageSliceRight - style.backgroundImageSliceLeft, style.backgroundImageSliceBottom - style.backgroundImageSliceTop);
		}
		
		if (slice == null) {
			
			var matrix:Matrix = null;
			
			if (style.backgroundImageRepeat == "stretch") {
				matrix = new Matrix();
				matrix.translate( -rect.x, -rect.y);
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
				sprite.pixels.draw(bmd, matrix, null, null, null);
			}
		}
		
		else {
			
			var rects = Slice9.buildRects(sprite.frameWidth, sprite.frameHeight, rect.width, rect.height, slice);
			
			var src = null;
			for (i in 0...rects.src.length) {
				
				src = rects.src[i];
				
				src.left += rect.x;
				src.top += rect.y;
			}
			
			var srcOpenFL = new Rectangle();
			var dstOpenFL = new Rectangle();
			var dstPt = new Point();
			var mat = new Matrix();
			
			var pixels = sprite.pixels;
			
			// 9-slice credit @MSGhero and @IBwWG: https://gist.github.com/IBwWG/9ffe25a059983e7e4eeb7640d6645a37
			
			// copyPx() the corners
			pixels.copyPixels(bmd, setOpenFLRect(srcOpenFL, rects.src[0]), setOpenFLRect(dstOpenFL, rects.dst[0]).topLeft, null, null, true); // TL
			pixels.copyPixels(bmd, setOpenFLRect(srcOpenFL, rects.src[2]), setOpenFLRect(dstOpenFL, rects.dst[2]).topLeft, null, null, true); // TR
			pixels.copyPixels(bmd, setOpenFLRect(srcOpenFL, rects.src[6]), setOpenFLRect(dstOpenFL, rects.dst[6]).topLeft, null, null, true); // BL
			pixels.copyPixels(bmd, setOpenFLRect(srcOpenFL, rects.src[8]), setOpenFLRect(dstOpenFL, rects.dst[8]).topLeft, null, null, true); // BR
			
			// draw() the sides and center
			var tl = rects.src[0];
			var center = rects.src[4];
			var br = rects.src[8];
			
			var scaleH = rects.dst[4].width / center.width;
			var scaleV = rects.dst[4].height / center.height;
			
			// is it better to draw() from bmd (scaling a large bmd) or from a temp copyPx slice (creates a new bmd each time)?
			
			setOpenFLRect(dstOpenFL, rects.dst[1]);
			mat.translate(tl.width * (1 / scaleH - 1) - rect.x, -rect.y);
			mat.scale(scaleH, 1);
			pixels.draw(bmd, mat, null, null, dstOpenFL); // T
			
			mat.identity();
			
			setOpenFLRect(dstOpenFL, rects.dst[3]);
			mat.translate( -rect.x, tl.height * (1 / scaleV - 1) - rect.y);
			mat.scale(1, scaleV);
			pixels.draw(bmd, mat, null, null, dstOpenFL); // L
			
			mat.identity();
			
			setOpenFLRect(dstOpenFL, rects.dst[4]);
			mat.translate(tl.width * (1 / scaleH - 1) - rect.x, tl.height * (1 / scaleV - 1) - rect.y);
			mat.scale(scaleH, scaleV);
			pixels.draw(bmd, mat, null, null, dstOpenFL); // C
			
			mat.identity();
			
			setOpenFLRect(dstOpenFL, rects.dst[5]);
			mat.translate(sprite.frameWidth - rect.width - rect.x, tl.height * (1 / scaleV - 1) - rect.y);
			mat.scale(1, scaleV);
			pixels.draw(bmd, mat, null, null, dstOpenFL); // R
			
			mat.identity();
			
			setOpenFLRect(dstOpenFL, rects.dst[7]);
			mat.translate(tl.width * (1 / scaleH - 1) - rect.x, sprite.frameHeight - rect.height - rect.y);
			mat.scale(scaleH, 1);
			pixels.draw(bmd, mat, null, null, dstOpenFL); // B
		}
	}
	
	static function setOpenFLRect(oflRect:flash.geom.Rectangle, uiRect:haxe.ui.geom.Rectangle):flash.geom.Rectangle {
		oflRect.setTo(uiRect.left, uiRect.top, uiRect.width, uiRect.height);
		return oflRect;
	}
}