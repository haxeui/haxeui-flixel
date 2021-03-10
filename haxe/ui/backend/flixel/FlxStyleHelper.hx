package haxe.ui.backend.flixel;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.util.FlxColor;
import haxe.ui.assets.ImageInfo;
import haxe.ui.geom.Slice9;
import haxe.ui.styles.Style;
import haxe.ui.util.ColorUtil;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class FlxStyleHelper {
    public static function applyStyle(sprite:FlxSprite, style:Style) {
		if (sprite == null || sprite.pixels == null) {
            return;
        }

		var pixels:BitmapData = sprite.pixels;
        
        var left:Float = 0;
        var top:Float = 0;
        var width:Float = sprite.frameWidth;
        var height:Float = sprite.frameHeight;
        
        if (width <= 0 || height <= 0) {
            return;
        }
        
        var rc:Rectangle = new Rectangle(top, left, width, height);
        
        pixels.fillRect(rc, 0x0);
        
        if (style.borderLeftSize != null && style.borderLeftSize != 0
            && style.borderLeftSize == style.borderRightSize
            && style.borderLeftSize == style.borderBottomSize
            && style.borderLeftSize == style.borderTopSize

            && style.borderLeftColor != null
            && style.borderLeftColor == style.borderRightColor
            && style.borderLeftColor == style.borderBottomColor
            && style.borderLeftColor == style.borderTopColor) {
                var borderSize = style.borderLeftSize;
                var opacity = style.borderOpacity == null ? 1 : style.borderOpacity;
                var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.borderLeftColor;
                
                pixels.fillRect(new Rectangle(rc.left, rc.top, rc.width, borderSize), color); // top
                pixels.fillRect(new Rectangle(rc.right - borderSize, rc.top + borderSize, borderSize, rc.height - (borderSize * 2)), color); // right
                pixels.fillRect(new Rectangle(rc.left, rc.height - borderSize, rc.width, borderSize), color); // bottom
                pixels.fillRect(new Rectangle(rc.left, rc.top + borderSize, borderSize, rc.height - (borderSize * 2)), color); // left 
                rc.inflate(-borderSize, -borderSize);
        } else { // compound border
            var org = rc.clone();
            
            if (style.borderTopSize != null && style.borderTopSize > 0) {
                var borderSize = style.borderTopSize;
                var opacity = style.borderOpacity == null ? 1 : style.borderOpacity;
                var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.borderTopColor;
                pixels.fillRect(new Rectangle(rc.left, rc.top, org.width, borderSize), color); // top
                rc.top += borderSize;
            }
            
            if (style.borderBottomSize != null && style.borderBottomSize > 0) {
                var borderSize = style.borderBottomSize;
                var opacity = style.borderOpacity == null ? 1 : style.borderOpacity;
                var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.borderBottomColor;
                pixels.fillRect(new Rectangle(rc.left, org.height - borderSize, rc.width, borderSize), color); // bottom
                rc.bottom -= borderSize;
            }
            
            if (style.borderLeftSize != null && style.borderLeftSize > 0) {
                var borderSize = style.borderLeftSize;
                var opacity = style.borderOpacity == null ? 1 : style.borderOpacity;
                var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.borderLeftColor;
                pixels.fillRect(new Rectangle(rc.left, rc.top, borderSize, org.height - rc.top), color); // left 
                rc.left += borderSize;
            }
            
            if (style.borderRightSize != null && style.borderRightSize > 0) {
                var borderSize = style.borderRightSize;
                var opacity = style.borderOpacity == null ? 1 : style.borderOpacity;
                var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.borderRightColor;
                pixels.fillRect(new Rectangle(org.width - borderSize, rc.top, borderSize, org.height), color); // right 
                rc.right -= borderSize;
            }
        }
        
        
        if (style.backgroundColor != null) {
			var opacity = style.backgroundOpacity == null ? 1 : style.backgroundOpacity;
            if (style.backgroundColorEnd != null && style.backgroundColor != style.backgroundColorEnd) {
                var gradientType:String = "vertical";
                if (style.backgroundGradientStyle != null) {
                    gradientType = style.backgroundGradientStyle;
                }

                var arr:Array<Int> = null;
                var n:Int = 0;
                var rcLine:Rectangle = new Rectangle();
                if (gradientType == "vertical") {
                    arr = ColorUtil.buildColorArray(style.backgroundColor, style.backgroundColorEnd, Std.int(rc.height));
                    for (c in arr) {
                        rcLine.setTo(rc.left, rc.top + n, rc.width, 1);
                        pixels.fillRect(rcLine, Std.int(opacity * 0xFF) << 24 | c);
                        n++;
                    }
                } else if (gradientType == "horizontal") {
                    arr = ColorUtil.buildColorArray(style.backgroundColor, style.backgroundColorEnd, Std.int(rc.width));
                    for (c in arr) {
                        rcLine.setTo(rc.left + n, rc.top, 1, rc.height);
                        pixels.fillRect(rcLine, Std.int(opacity * 0xFF) << 24 | c);
                        n++;
                    }
                }
            } else {
                var color:FlxColor = Std.int(opacity * 0xFF) << 24 | style.backgroundColor;
                pixels.fillRect(rc, color);
            }
        }
        
        if (style.backgroundImage != null) {
            Toolkit.assets.getImage(style.backgroundImage, function(info:ImageInfo) {
                if (info != null && info.data != null) {
                    paintBackroundImage(sprite, info.data, style);
                }
            });
        }
    }
    
    private static function paintBackroundImage(sprite:FlxSprite, data:ImageData, style:Style) {
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
			
			sprite.dirty = true;
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
