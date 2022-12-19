package haxe.ui.backend.flixel;

import haxe.ui.styles.Style;
import openfl.display.GradientType;
import openfl.display.Graphics;
import openfl.display.InterpolationMethod;
import openfl.display.SpreadMethod;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class OpenFLStyleHelper {
    public function new() {
    }

    public static function paintStyleSection(graphics:Graphics, style:Style, width:Float, height:Float, left:Float = 0, top:Float = 0, clear:Bool = true) {
        if (clear == true) {
            graphics.clear();
        }

        if (width <= 0 || height <= 0) {
            return;
        }

        /*
        left = Math.fround(left);
        top = Math.fround(top);
        width = Math.fround(width);
        height = Math.fround(height);
        */

        left = Std.int(left);
        top = Std.int(top);
        width = Std.int(width);
        height = Std.int(height);

        var hasFullStyledBorder:Bool = false;
        var borderStyle = style.borderStyle;
        if (borderStyle == null) {
            borderStyle = "solid";
        }
        
        var rc:Rectangle = new Rectangle(top, left, width, height);
        var borderRadius:Float = 0;
        if (style.borderRadius != null) {
            borderRadius = style.borderRadius * Toolkit.scale;
        }

        if (style.borderLeftSize != null && style.borderLeftSize != 0
            && style.borderLeftSize == style.borderRightSize
            && style.borderLeftSize == style.borderBottomSize
            && style.borderLeftSize == style.borderTopSize

            && style.borderLeftColor != null
            && style.borderLeftColor == style.borderRightColor
            && style.borderLeftColor == style.borderBottomColor
            && style.borderLeftColor == style.borderTopColor) { // full border
            
            graphics.lineStyle(style.borderLeftSize * Toolkit.scale, style.borderLeftColor);
            rc.left += (style.borderLeftSize * Toolkit.scale) / 2;
            rc.top += (style.borderLeftSize * Toolkit.scale) / 2;
            rc.bottom -= (style.borderLeftSize * Toolkit.scale) / 2;
            rc.right -= (style.borderLeftSize * Toolkit.scale) / 2;
            //rc.inflate( -(style.borderLeftSize / 2), -(style.borderLeftSize / 2));
        } else { // compound border
            if ((style.borderTopSize != null && style.borderTopSize > 0)
                || (style.borderBottomSize != null && style.borderBottomSize > 0)
                || (style.borderLeftSize != null && style.borderLeftSize > 0)
                || (style.borderRightSize != null && style.borderRightSize > 0)) {

                    var org = rc.clone();
                    
                    if (style.borderTopSize != null && style.borderTopSize > 0) {
                        graphics.beginFill(style.borderTopColor);
                        graphics.drawRect(0, 0, org.width, (style.borderTopSize * Toolkit.scale));
                        graphics.endFill();

                        rc.top += (style.borderTopSize * Toolkit.scale);
                    }

                    if (style.borderBottomSize != null && style.borderBottomSize > 0) {
                        graphics.beginFill(style.borderBottomColor);
                        graphics.drawRect(0, org.height - (style.borderBottomSize * Toolkit.scale), org.width, (style.borderBottomSize * Toolkit.scale));
                        graphics.endFill();

                        rc.bottom -= (style.borderBottomSize * Toolkit.scale);
                    }

                    if (style.borderLeftSize != null && style.borderLeftSize > 0) {
                        graphics.beginFill(style.borderLeftColor);
                        graphics.drawRect(0, rc.top, (style.borderLeftSize * Toolkit.scale), org.height - rc.top);
                        graphics.endFill();

                        rc.left += (style.borderLeftSize * Toolkit.scale);
                    }

                    if (style.borderRightSize != null && style.borderRightSize > 0) {
                        graphics.beginFill(style.borderRightColor);
                        graphics.drawRect(org.width - (style.borderRightSize * Toolkit.scale), rc.top, (style.borderRightSize * Toolkit.scale), org.height - rc.top);
                        graphics.endFill();

                        rc.right -= (style.borderRightSize * Toolkit.scale);
                    }
            }
        }

        var backgroundColor:Null<Int> = style.backgroundColor;
        var backgroundColorEnd:Null<Int> = style.backgroundColorEnd;
        var backgroundOpacity:Null<Float> = style.backgroundOpacity;
        #if html5 // TODO: fix for html5 not working with non-gradient fills
        if (backgroundColor != null && backgroundColorEnd == null) {
            backgroundColorEnd = backgroundColor;
        }
        #end

        if(backgroundOpacity == null) {
            backgroundOpacity = 1;
        }

        if (backgroundColor != null) {
            if (backgroundColorEnd != null) {
                var w:Int = Std.int(rc.width);
                var h:Int = Std.int(rc.height);
                var colors:Array<UInt> = [backgroundColor, backgroundColorEnd];
                var alphas:Array<Float> = [backgroundOpacity, backgroundOpacity];
                var ratios:Array<Int> = [0, 255];
                var matrix:Matrix = new Matrix();

                var gradientType:String = "vertical";
                if (style.backgroundGradientStyle != null) {
                    gradientType = style.backgroundGradientStyle;
                }

                if (gradientType == "vertical") {
                    matrix.createGradientBox(w - 2, h - 2, Math.PI / 2, 0, 0);
                } else if (gradientType == "horizontal") {
                    matrix.createGradientBox(w - 2, h - 2, 0, 0, 0);
                }

                graphics.beginGradientFill(GradientType.LINEAR,
                                            colors,
                                            alphas,
                                            ratios,
                                            matrix,
                                            SpreadMethod.PAD,
                                            InterpolationMethod.LINEAR_RGB,
                                            0);
            } else {
                graphics.beginFill(backgroundColor, backgroundOpacity);
            }
        }

        if (borderRadius == 0) {
            if (style.borderRadiusTopLeft != null || style.borderRadiusTopRight != null || style.borderRadiusBottomLeft != null || style.borderRadiusBottomRight != null) {
                graphics.drawRoundRectComplex(rc.left, rc.top, rc.width, rc.height, style.borderRadiusTopLeft, style.borderRadiusTopRight, style.borderRadiusBottomLeft, style.borderRadiusBottomRight);
            } else if (hasFullStyledBorder) {
                graphics.drawRect(rc.left, rc.top, rc.width, rc.height);
            } else {
                graphics.drawRect(rc.left, rc.top, rc.width, rc.height);
            }
        } else {
            if (rc.width == rc.height && borderRadius >= rc.width / 2) {
                borderRadius = rc.width - 1;
            }
            graphics.drawRoundRect(rc.left, rc.top, rc.width, rc.height, borderRadius + 1, borderRadius + 1);
        }

        graphics.endFill();
    }
}