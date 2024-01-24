package haxe.ui.backend.flixel.components;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;

@:composite(Layout)
class SpriteWrapper extends Box {
    public var spriteOffsetX:Float = 0;
    public var spriteOffsetY:Float = 0;

    private var _sprite:FlxSprite = null;
    public var sprite(get, set):FlxSprite;
    private function get_sprite():FlxSprite {
        return _sprite;
    }
    private function set_sprite(value:FlxSprite):FlxSprite {
        if (_sprite != null) {
            remove(_sprite);
        }
        _sprite = value;
        add(_sprite);
        invalidateComponentLayout();
        return value;
    }

    private override function repositionChildren() {
        super.repositionChildren();
        if (sprite != null) {
            sprite.x = spriteOffsetX + this.screenX;
            sprite.y = spriteOffsetY + this.screenY;
        }
    }
}

@:access(haxe.ui.backend.flixel.components.SpriteWrapper)
private class Layout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();

        var wrapper = cast(_component, SpriteWrapper);
        var sprite = wrapper.sprite;
        if (sprite == null) {
            return super.resizeChildren();
        }

        sprite.origin.set(0, 0);
        sprite.setGraphicSize(Std.int(innerWidth), Std.int(innerHeight));
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var wrapper = cast(_component, SpriteWrapper);
        var sprite = wrapper.sprite;
        if (sprite == null) {
            return super.calcAutoSize(exclusions);
        }
        var size = new Size();
        size.width = sprite.width + paddingLeft + paddingRight;
        size.height = sprite.height + paddingTop + paddingBottom;
        return size;
    }
}