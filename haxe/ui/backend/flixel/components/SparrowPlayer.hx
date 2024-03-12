package haxe.ui.backend.flixel.components;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.data.DataSource;
import haxe.ui.events.AnimationEvent;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;
import openfl.Assets;

private typedef AnimationInfo = {
    var name:String;
    var prefix:String;
    var frameRate:Null<Int>; // default 30
    var looped:Null<Bool>; // default true
    var flipX:Null<Bool>; // default false
    var flipY:Null<Bool>; // default false
}

/*
<sparrow-player id="player1" xmlFile="assets/sparrow/test01/BOYFRIEND.xml" pngFile="assets/sparrow/test01/BOYFRIEND.png" animationName="idle">
    <data>
        <set name="note up" prefix="BF NOTE UP" frameRate="24" looped="true" />
        <set name="dies" prefix="BF dies" frameRate="24" looped="true" />
        <set name="dead loop" prefix="BF Dead Loop" frameRate="24" looped="true" />
        <set name="dead confirm" prefix="BF Dead confirm" frameRate="24" looped="true" />
    </data>
</sparrow-player>
*/

@:composite(Layout)
class SparrowPlayer extends Box implements IDataComponent {
    private var sprite:FlxSprite;

    public function new() {
        super();
        sprite = new FlxSprite(1, 1);
        add(sprite);
    }

    private var _xmlFile:String;
    public var xmlFile(get, set):String;
    private function get_xmlFile():String {
        return _xmlFile;
    }
    private function set_xmlFile(value:String):String {
        _xmlFile = value;
        loadAnimation(_xmlFile, _pngFile);
        return value;
    }

    private var _pngFile:String;
    public var pngFile(get, set):String;
    private function get_pngFile():String {
        return _pngFile;
    }
    private function set_pngFile(value:String):String {
        _pngFile = value;
        loadAnimation(_xmlFile, _pngFile);
        return value;
    }

    private var _dataSource:DataSource<Dynamic> = null;
    private override function get_dataSource():DataSource<Dynamic> {
        return _dataSource;
    }
    private override function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        _dataSource = value;
        for (i in 0..._dataSource.size) {
            var item:Dynamic = _dataSource.get(i);
            if (item.frameRate == null) {
                item.frameRate = 30;
            }
            if (item.looped == null) {
                item.looped = true;
            }
            if (item.flipX == null) {
                item.flipX = false;
            }
            if (item.flipY == null) {
                item.flipY = false;
            }
            addAnimationByPrefix(item.name, item.prefix, Std.parseInt(item.frameRate), Std.string(item.looped) == "true", Std.string(item.flipX) == "true", Std.string(item.flipY) == "true");
        }
        return value;
    }

    private var _cachedAnimationName:String = null; // component might not have an animation yet, so we'll cache it if thats the case
    private var _animationName:String = null;
    public var animationName(get, set):String;
    private function get_animationName() {
        return _animationName;
    }
    private function set_animationName(value:String):String {
        if (!_animationLoaded) {
            _cachedAnimationName = value;
            return value;
        }

        if (sprite.animation.getByName(value) != null) {
            _cachedAnimationName = null;
            _animationName = value;
            sprite.animation.play(_animationName);
            invalidateComponentLayout();

            if (hasEvent(AnimationEvent.START)) {
                dispatch(new AnimationEvent(AnimationEvent.START));
            } else {
                _redispatchStart = true;
            }
        } else {
            _cachedAnimationName = value;
        }
        return value;
    }

    private var _redispatchLoaded:Bool = false; // possible haxeui bug: if listener is added after event is dispatched, event is "lost"... needs thinking about, is it smart to "collect and redispatch"? Not sure
    private var _redispatchStart:Bool = false; // possible haxeui bug: if listener is added after event is dispatched, event is "lost"... needs thinking about, is it smart to "collect and redispatch"? Not sure
    public override function onReady() {
        super.onReady();
        if (_cachedAnimationName != null) {
            animationName = _cachedAnimationName;
        }
        invalidateComponentLayout();

        if (_redispatchLoaded) {
            _redispatchLoaded = false;
            dispatch(new AnimationEvent(AnimationEvent.LOADED));
        }

        if (_redispatchStart) {
            _redispatchStart = false;
            dispatch(new AnimationEvent(AnimationEvent.START));
        }
    }

    private var _cachedAnimationPrefixes:Array<AnimationInfo> = []; // component might not have an animation yet, so we'll cache it if thats the case
    public function addAnimationByPrefix(name:String, prefix:String, frameRate:Int = 30, looped:Bool = true, flipX:Bool = false, flipY:Bool = false) {
        if (!_animationLoaded) {
            if (_cachedAnimationPrefixes == null) {
                _cachedAnimationPrefixes = [];
            }
            _cachedAnimationPrefixes.push({
                name: name,
                prefix: prefix,
                frameRate: frameRate,
                looped: looped,
                flipX: flipX,
                flipY: flipY
            });
            return;
        }

        sprite.animation.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);
        if (_cachedAnimationName != null) {
            animationName = _cachedAnimationName;
        }
    }

    private var _animationLoaded:Bool = false;
    public function loadAnimation(xml:String, png:String) {
        if (xml == null || png == null) {
            return;
        }

        var frames:FlxFramesCollection = FlxAtlasFrames.fromSparrow(png, Assets.getText(xml));
        sprite.frames = frames;
        if (sprite.animation.callback == null) {
            sprite.animation.callback = onFrame;
        }
        if (sprite.animation.finishCallback == null) {
            sprite.animation.finishCallback = onFinish;
        }
        invalidateComponentLayout();
        _animationLoaded = true;

        if (_cachedAnimationPrefixes != null) {
            while (_cachedAnimationPrefixes.length > 0) {
                var item = _cachedAnimationPrefixes.shift();
                addAnimationByPrefix(item.name, item.prefix, item.frameRate, item.looped, item.flipX, item.flipY);
            }
            _cachedAnimationPrefixes = null;
        }

        if (_cachedAnimationName != null) {
            animationName = _cachedAnimationName;
        }

        if (hasEvent(AnimationEvent.LOADED)) {
            dispatch(new AnimationEvent(AnimationEvent.LOADED));
        } else {
            _redispatchLoaded = true;
        }
    }

    public var currentFrameCount(get, null):Int;
    private function get_currentFrameCount() {
        if (sprite.animation == null || sprite.animation.curAnim == null) {
            return 0;
        }

        return sprite.animation.curAnim.numFrames;
    }

    public var currentFrameNumber(get, null):Int;
    private function get_currentFrameNumber() {
        if (sprite.animation == null || sprite.animation.curAnim == null) {
            return 0;
        }

        return sprite.animation.curAnim.curFrame;
    }

    public var frameNames(get, null):Array<String>;
    private function get_frameNames():Array<String> {
        if (sprite.animation == null) {
            return [];
        }

        return sprite.animation.getNameList();
    }

    private function onFrame(name:String, frameNumber:Int, frameIndex:Int) {
        dispatch(new AnimationEvent(AnimationEvent.FRAME));
    }

    private function onFinish(name:String) {
        dispatch(new AnimationEvent(AnimationEvent.END));
    }

    /*
    // lets override a few flixel / haxeui-flixel specifics to get things nice and smooth
    public override function update(elapsed:Float) {
        super.update(elapsed);
        // these lines make the clipping _much_ better but im not sure if its smart
        var cc = findClipComponent();
        if (cc != null) {
            var cr = cc.componentClipRect;
            var rc = FlxRect.get(screenLeft + cr.left, screenTop + cr.top, cr.width, cr.height);
            this.clipRect = rc;
            rc.put();
        }
    }
    */

    private override function repositionChildren() {
        super.repositionChildren();
        sprite.x = this.screenX;
        sprite.y = this.screenY;
    }
}

@:access(haxe.ui.backend.flixel.components.SparrowPlayer)
private class Layout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();

        var player = cast(_component, SparrowPlayer);
        var sprite = player.sprite;
        if (sprite == null) {
            return super.resizeChildren();
        }

        sprite.origin.set(0, 0);
        sprite.setGraphicSize(Std.int(innerWidth), Std.int(innerHeight));
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var player = cast(_component, SparrowPlayer);
        var sprite = player.sprite;
        if (sprite == null) {
            return super.calcAutoSize(exclusions);
        }
        var size = new Size();
        size.width = sprite.frameWidth + paddingLeft + paddingRight;
        size.height = sprite.frameHeight + paddingTop + paddingBottom;
        return size;
    }
}