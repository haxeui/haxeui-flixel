package haxe.ui.backend;

import flixel.FlxSprite;
import haxe.io.Bytes;
import haxe.ui.core.Component;
import haxe.ui.loaders.image.ImageLoader;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;
import openfl.display.BitmapData;
import openfl.display.GraphicsPath;
import openfl.display.GraphicsPathCommand;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

@:allow(haxe.ui.backend.ComponentGraphicsSprite)
class ComponentGraphicsImpl extends ComponentGraphicsBase {
    private var _hasSize:Bool = false;
    private var bitmapData:BitmapData = null;
    private var sprite:ComponentGraphicsSprite;

    private var flashGfxSprite:Sprite = new Sprite();

    private var _currentFillColor:Null<Color> = null;
    private var _currentFillAlpha:Null<Float> = null;
    private var _globalFillColor:Null<Color> = null;
    private var _globalFillAlpha:Null<Float> = null;

    private var _globalLineThickness:Null<Float> = null;
    private var _globalLineColor:Null<Color> = null;
    private var _globalLineAlpha:Null<Float> = null;

    private var currentPath:GraphicsPath;

    public function new(component:Component) {
        super(component);
        sprite = new ComponentGraphicsSprite(this);
        sprite.active = false;
        sprite.visible = false;
        _component.add(sprite);
    }

    public override function clear() {
        super.clear();
        if (_hasSize == false) {
            return;
        }
        flashGfxSprite.graphics.clear();
        
        sprite.pixels.fillRect(sprite.pixels.rect, 0x00000000);
        sprite._needsDraw = true;
    }

    public override function setPixel(x:Float, y:Float, color:Color) {
        super.setPixel(x, y, color);
        if (_hasSize == false) {
            return;
        }
        flashGfxSprite.graphics.beginFill(color);
        flashGfxSprite.graphics.drawRect(x, y, 1, 1);
        flashGfxSprite.graphics.endFill();
        sprite._needsDraw = true;
    }

    public override function setPixels(pixels:Bytes) {
        super.setPixels(pixels);
        if (_hasSize == false) {
            return;
        }

        var w = Std.int(_component.width);
        var h = Std.int(_component.height);

        if (bitmapData != null && (bitmapData.width != w || bitmapData.height != h)) {
            bitmapData.dispose();
            bitmapData = null;
        }

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

        sprite.width = w;
        sprite.height = h;

        sprite.pixels = bitmapData;
        sprite.visible = (w > 0 && h > 0);
    }

    public override function moveTo(x:Float, y:Float) {
        super.moveTo(x, y);
        if (_hasSize == false) {
            return;
        }
        if (currentPath != null) {
            currentPath.moveTo(x, y);
        } else {
            flashGfxSprite.graphics.moveTo(x, y);
            sprite._needsDraw = true;
        }
    }

    public override function lineTo(x:Float, y:Float) {
        super.lineTo(x, y);
        if (_hasSize == false) {
            return;
        }
        if (currentPath != null) {
            currentPath.lineTo(x, y);
        } else {
            flashGfxSprite.graphics.lineTo(x, y);
            sprite._needsDraw = true;
        }
    }

    public override function strokeStyle(color:Null<Color>, thickness:Null<Float> = 1, alpha:Null<Float> = 1) {
        super.strokeStyle(color, thickness, alpha);
        if (_hasSize == false) {
            return;
        }
        if (currentPath == null) { 
            _globalLineThickness = thickness;
            _globalLineColor = color;
            _globalLineAlpha = alpha;
        }
        
        flashGfxSprite.graphics.lineStyle(thickness, color, alpha);
    }

    public override function circle(x:Float, y:Float, radius:Float) {
        super.circle(x, y, radius);
        if (_hasSize == false) {
            return;
        }
        if (_currentFillColor != null) {
            flashGfxSprite.graphics.beginFill(_currentFillColor, _currentFillAlpha);
        }
        flashGfxSprite.graphics.drawCircle(x, y, radius);
        if (_currentFillColor != null) {
            flashGfxSprite.graphics.endFill();
        }
        sprite._needsDraw = true;
    }

    public override function fillStyle(color:Null<Color>, alpha:Null<Float> = 1) {
        super.fillStyle(color, alpha);
        if (_hasSize == false) {
            return;
        }
        if (currentPath == null) {
            _globalFillColor = color;
            _globalFillAlpha = alpha;
        }
        _currentFillColor = color;
        _currentFillAlpha = alpha;
    }

    public override  function curveTo(controlX:Float, controlY:Float, anchorX:Float, anchorY:Float) {
        super.curveTo(controlX, controlY, anchorX, anchorY);
        if (_hasSize == false) {
            return;
        }
        
        if (currentPath != null) {
            currentPath.curveTo(controlX, controlY, anchorX, anchorY);
        } else {
            flashGfxSprite.graphics.curveTo(controlX, controlY, anchorX, anchorY);
            sprite._needsDraw = true;
        }
    }

    public override function cubicCurveTo(controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float) {
        super.cubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
        if (_hasSize == false) {
            return;
        }
        if (currentPath != null) {
            currentPath.cubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
        } else {
            flashGfxSprite.graphics.cubicCurveTo(controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
            sprite._needsDraw = true;
        }
    }

    public override function rectangle(x:Float, y:Float, width:Float, height:Float) {
        super.rectangle(x, y, width, height);
        if (_hasSize == false) {
            return;
        }
        if (_currentFillColor != null) {
            flashGfxSprite.graphics.beginFill(_currentFillColor, _currentFillAlpha);
        }
        flashGfxSprite.graphics.drawRect(x, y, width, height);
        if (_currentFillColor != null) {
            flashGfxSprite.graphics.endFill();
        }
        sprite._needsDraw = true;
    }

    public override function image(resource:Variant, x:Null<Float> = null, y:Null<Float> = null, width:Null<Float> = null, height:Null<Float> = null) {
        super.image(resource, x, y, width, height);
        if (_hasSize == false) {
            return;
        }
        ImageLoader.instance.load(resource, function(imageInfo) {
            if (imageInfo != null) {
                if (x == null) x = 0;
                if (y == null) y = 0;
                if (width == null) width = imageInfo.width;
                if (height == null) height = imageInfo.height;
                
                var mat:Matrix = new Matrix();
                mat.scale(width / imageInfo.width, height / imageInfo.width);
                mat.translate(x, y);
                
                flashGfxSprite.graphics.beginBitmapFill(imageInfo.data.parent.bitmap, mat);
                flashGfxSprite.graphics.drawRect(x, y, width, height);
                flashGfxSprite.graphics.endFill();
                sprite._needsDraw = true;
            } else {
                trace("could not load: " + resource);
            }
        });
    }

    public override function beginPath() {
        super.beginPath();
        if (_hasSize == false) {
            return;
        }
        currentPath = new GraphicsPath();
    }

    public override function closePath() {
        super.closePath();
        if (_hasSize == false) {
            return;
        }
        if (currentPath != null && currentPath.commands != null && currentPath.commands.length > 0) {
            if (_currentFillColor != null) {
                flashGfxSprite.graphics.beginFill(_currentFillColor, _currentFillAlpha);
            }
            if (currentPath.commands[0] != GraphicsPathCommand.MOVE_TO) {
                currentPath.commands.insertAt(0, GraphicsPathCommand.MOVE_TO);
                @:privateAccess currentPath.data.insertAt(0, flashGfxSprite.graphics.__positionX);
                @:privateAccess currentPath.data.insertAt(0, flashGfxSprite.graphics.__positionY);
            }
            flashGfxSprite.graphics.drawPath(currentPath.commands, currentPath.data);
            if (_currentFillColor != null) {
                flashGfxSprite.graphics.endFill();
            }
            sprite._needsDraw = true;
        }
        currentPath = null; 
        _currentFillColor = _globalFillColor;
        _currentFillAlpha = _globalFillAlpha;

        // it seems openfl forgets about lineStyle after drawing a shape;
        flashGfxSprite.graphics.lineStyle(_globalLineThickness, _globalLineColor, _globalLineAlpha);
    }

    public override function resize(width:Null<Float>, height:Null<Float>) {
        if (width > 0 && height > 0) {
            if (_hasSize == false) {
                _hasSize = true;
                sprite.makeGraphic(Std.int(width), Std.int(height), 0x00000000, true);
                sprite.visible = true;
                replayDrawCommands();
            }
        }
    }
}

@:allow(haxe.ui.backend.ComponentGraphicsImpl)
class ComponentGraphicsSprite extends FlxSprite {
    private var componentGraphics:ComponentGraphicsImpl;

    private var _needsDraw:Bool = false;

    public function new(componentGraphics:ComponentGraphicsImpl) {
        super();
        this.componentGraphics = componentGraphics;
    }

    public override function draw() {
        if (pixels != null && _needsDraw) {
            pixels.draw(componentGraphics.flashGfxSprite);
            _needsDraw = false;
        }
        super.draw();
    }
}