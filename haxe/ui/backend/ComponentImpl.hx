package haxe.ui.backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.text.FlxText.FlxTextBorderStyle;
import haxe.ui.Toolkit;
import haxe.ui.backend.TextInputImpl.TextInputEvent;
import haxe.ui.backend.flixel.FlxStyleHelper;
import haxe.ui.backend.flixel.MouseHelper;
import haxe.ui.backend.flixel.StateHelper;
import haxe.ui.core.Component;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.Platform;
import haxe.ui.core.Screen;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.filters.DropShadow;
import haxe.ui.filters.Outline;
import haxe.ui.geom.Rectangle;
import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;
import openfl.events.Event;

class ComponentImpl extends ComponentBase {
    private var _eventMap:Map<String, UIEvent->Void>;
    
    private var _surface:FlxSprite;
    
    private var lastMouseX:Float = -1;
    private var lastMouseY:Float = -1;
    
    // For doubleclick detection
    private var _lastClickTime:Float = 0;
    private var _lastClickTimeDiff:Float = MathUtil.MAX_INT;
    private var _lastClickX:Float = -1;
    private var _lastClickY:Float = -1;
    
    private var asComponent:Component;

    public function new() {
        super();
        _eventMap = new Map<String, UIEvent->Void>();
        
        this.pixelPerfectRender = true;
        this.moves = false;
        superVisible(false);
        
        asComponent = cast(this, Component);
        
        if (Platform.instance.isMobile) {
            asComponent.addClass(":mobile");
        }
        
        scrollFactor.set(0, 0); // ui doesn't scroll by default

        _surface = new FlxSprite();
        _surface.makeGraphic(1, 1, 0x0, true);
        _surface.pixelPerfectRender = true;
        _surface.moves = false;
        add(_surface);
        
        //recursiveReady();
    }
    
    private function recursiveReady() {
        asComponent.ready();
        for (child in asComponent.childComponents) {
            child.recursiveReady();
        }
    }
    
    private var _state:FlxState;
    public var state(get, set):FlxState;
    private function get_state():FlxState {
        return findRootComponent()._state;
    }
    private function set_state(value:FlxState):FlxState {
        findRootComponent()._state = value;
        return value;
    }


    // lets cache certain items so we dont have to loop multiple times per frame
    private var _cachedScreenX:Null<Float> = null;
    private var _cachedScreenY:Null<Float> = null;
    private var _cachedClipComponent:Component = null;
    private var _cachedClipComponentNone:Null<Bool> = null;
    private var _cachedRootComponent:Component = null;
    
    private function clearCaches() {
        _cachedScreenX = null;
        _cachedScreenY = null;
        _cachedClipComponent = null;
        _cachedClipComponentNone = null;
        _cachedRootComponent = null;
    }
    
    private function cacheScreenPos() {
        if (_cachedScreenX != null && _cachedScreenY != null) {
            return;
        }
        
        var c:Component = asComponent;
        var xpos:Float = 0;
        var ypos:Float = 0;
        while (c != null) {
            xpos += c.left;
            ypos += c.top;
            if (c.componentClipRect != null) {
                xpos -= c.componentClipRect.left;
                ypos -= c.componentClipRect.top;
            }
            c = c.parentComponent;
        }
        
        _cachedScreenX = xpos * Toolkit.scaleX;
        _cachedScreenY = ypos * Toolkit.scaleY;
    }
    
    private var screenX(get, null):Float;
    private function get_screenX():Float {
        cacheScreenPos();
        return _cachedScreenX;
    }

    private var screenY(get, null):Float;
    private function get_screenY():Float {
        cacheScreenPos();
        return _cachedScreenY;
    }

    private function findRootComponent():Component {
        if (_cachedRootComponent != null) {
            return _cachedRootComponent;
        }
        
        var c:Component = asComponent;
        while (c.parentComponent != null) {
            c = c.parentComponent;
        }
        
        _cachedRootComponent = c;
        
        return c;
    }
    
    private function isRootComponent():Bool {
        return (findRootComponent() == this);
    }
    
    private function findClipComponent():Component {
        if (_cachedClipComponent != null) {
            return _cachedClipComponent;
        } else if (_cachedClipComponentNone == true) {
            return null;
        }
        
        var c:Component = asComponent;
        var clip:Component = null;
        while (c != null) {
            if (c.componentClipRect != null) {
                clip = c;
                break;
            }
            c = c.parentComponent;
        }

        _cachedClipComponent = clip;
        if (clip == null) {
            _cachedClipComponentNone = true;
        }
        
        return clip;
    }

    @:access(haxe.ui.core.Component)
    private function inBounds(x:Float, y:Float):Bool {
        if (asComponent.hidden == true) {
            return false;
        }

        var b:Bool = false;
        var sx = screenX;
        var sy = screenY;
        var cx = asComponent.componentWidth * Toolkit.scaleX;
        var cy = asComponent.componentHeight * Toolkit.scaleY;

        if (x >= sx && y >= sy && x <= sx + cx && y < sy + cy) {
            b = true;
        }

        // let make sure its in the clip rect too
        if (b == true) {
            var clip:Component = findClipComponent();
            if (clip != null) {
                b = false;
                var sx = (clip.screenX + (clip.componentClipRect.left * Toolkit.scaleX));
                var sy = (clip.screenY + (clip.componentClipRect.top * Toolkit.scaleY));
                var cx = clip.componentClipRect.width * Toolkit.scaleX;
                var cy = clip.componentClipRect.height * Toolkit.scaleY;
                if (x >= sx && y >= sy && x <= sx + cx && y < sy + cy) {
                    b = true;
                }
            }
        }
        return b;
    }
    
    private override function handlePosition(left:Null<Float>, top:Null<Float>, style:Style) {
        if (left == null && top == null) {
            return;
        }
        
        if (parentComponent == null) {
            if (left != null) {
                this.x = left;
            }
            if (top != null) {
                this.y = top;
            }
        }
    }
    
    private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
        if (_surface == null) {
            return;
        }
        
        if (width == null || height == null) {
            return;
        }
        
        var w:Int = Std.int(width * Toolkit.scaleX);
        var h:Int = Std.int(height * Toolkit.scaleY);
        if (_surface.width != w || _surface.height != h) {
            if (w <= 0 || h <= 0) {
                _surface.graphic.destroy();
                _surface.makeGraphic(1, 1, 0x0, true);
            } else {
                _surface.graphic.destroy();
                _surface.makeGraphic(w, h, 0x0, true);
                applyStyle(style);
            }
        }
    }
    
    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************
    
    private override function handleSetComponentIndex(child:Component, index:Int) {
        handleAddComponentAt(child, index);
    }

    private override function handleAddComponent(child:Component):Component {
        handleAddComponentAt(child, childComponents.length - 1);
        return child;
    }

    private function superVisible(value:Bool) {
        _skipTransformChildren = true;
        super.set_visible(value);
        _skipTransformChildren = false;
    }

    private override function handleAddComponentAt(child:Component, index:Int):Component {
        // index is in terms of haxeui components, not flixel children
        var indexOffset = 0;
        while (indexOffset < members.length) {
            if (!(members[indexOffset] is Component)) {
                indexOffset++;
            } else{
                break;
            }
        }

        insert(index + indexOffset, child);
        return child;
    }
    
    private var _unsolicitedMembers:Array<{sprite: FlxSprite, originalX:Float, originalY:Float}> = null;
    private override function preAdd(sprite:FlxSprite) {
        if (isUnsolicitedMember(sprite)) {
            if (_unsolicitedMembers == null) {
                _unsolicitedMembers = [];
            }
            if (findUnsolictedEntryFromSprite(sprite) == null) {
                var use = true;
                if (_textInput != null && _textInput.equals(sprite)) {
                    use = false;
                }
                if (use) {
                    _unsolicitedMembers.push({
                        sprite: sprite,
                        originalX: sprite.x,
                        originalY: sprite.y
                    });
                }
            }
        }
        super.preAdd(sprite);
    }

    public override function remove(sprite:FlxSprite, splice:Bool = false):FlxSprite {
        if (isUnsolicitedMember(sprite) && _unsolicitedMembers != null) {
            var um = findUnsolictedEntryFromSprite(sprite);
            _unsolicitedMembers.remove(um);
        }
        return super.remove(sprite, splice);
    }
    
    private function findUnsolictedEntryFromSprite(sprite:FlxSprite):{sprite: FlxSprite, originalX:Float, originalY:Float} {
        if (_unsolicitedMembers == null) {
            return null;
        }
        for (um in _unsolicitedMembers) {
            if (um.sprite == sprite) {
                return um;
            }
        }
        return null;
    }

    private var _destroy:Bool = false;
    private override function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
        if (this.exists == false) { // lets make sure this component exists - it could have been destroyed through a variety of different ways already (like switching state for example, or simply manually destroying it)
            return child;
        }
        if (members.indexOf(child) > -1) {
            remove(child, true);
            if (dispose == true) {
                child._destroy = true;
                child.destroyInternal();
            }
        }
        return child;
    }

    private override function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
        return handleRemoveComponent(this.childComponents[index], dispose);
    }
    
    private override function handleClipRect(value:Rectangle):Void {
        if (value == null) {
            clipRect = null;
        }
    }

    private override function handleVisibility(show:Bool):Void {
        applyVisibility(show);
    }

    private function applyVisibility(show:Bool):Void {
        superVisible(show);

        if (hasTextDisplay()) {
            _textDisplay.tf.visible = show;
        }
        if (hasTextInput()) {
            _textInput.visible = show;
        }

        for (c in this.childComponents) {
            if (!c.hidden) {
                c.applyVisibility(show);
            }
        }
    }

    //***********************************************************************************************************
    // Style
    //***********************************************************************************************************
    private override function applyStyle(style:Style) {
        if (style.opacity != null) {
            applyAlpha(style.opacity);
        } else if (_surface.alpha != 1) {
            //applyAlpha(1);
        }
        
        /*
        if (style != null && style.cursor != null && _mouseOverFlag) {
            Screen.instance.setCursor(this.style.cursor, this.style.cursorOffsetX, this.style.cursorOffsetY);
            _cursorSet = true;
        }
        */

        FlxStyleHelper.applyStyle(_surface, style);
        applyFilters(style);
    }
    
    private function applyAlpha(value:Float) {
        _surface.alpha = value;
        if (hasTextDisplay()) {
            getTextDisplay().tf.alpha = value;
        }
        if (hasTextInput()) {
            getTextInput().alpha = value;
        }
        if (hasImageDisplay()) {
            getImageDisplay().alpha = value;
        }
        for (c in childComponents) {
            c.applyAlpha(value);
        }
    }

    public override function set_alpha(alpha:Float):Float {
        _surface.alpha = alpha;
        if (hasTextDisplay()) {
            getTextDisplay().tf.alpha = alpha;
        }
        if (hasTextInput()) {
            getTextInput().alpha = alpha;
        }
        if (hasImageDisplay()) {
            getImageDisplay().alpha = alpha;
        }
        return super.set_alpha(alpha);
    }
    
    private function applyFilters(style:Style) {
        if (style.filter != null && style.filter.length > 0) {
            for (f in style.filter) {
                if (_textDisplay != null && (f is Outline)) {
                    var o = cast(f, Outline);
                    var col = o.color;
                    _textDisplay.tf.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000 | o.color, o.size);
                } else if (_textDisplay != null && (f is DropShadow)) {
                    var o = cast(f, DropShadow);
                    _textDisplay.tf.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF000000 | o.color, o.distance);
                }
            }
        }
    }
    
    //***********************************************************************************************************
    // Image
    //***********************************************************************************************************
    public override function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            super.createImageDisplay();
            _imageDisplay.visible = false;
            add(_imageDisplay);
            Toolkit.callLater(function() { // lets show it a frame later so its had a chance to reposition
                if (_imageDisplay != null) {
                    _imageDisplay.visible = true;
                }
            });
        }
        
        return _imageDisplay;
    }
    
    public override function removeImageDisplay():Void {
        if (_imageDisplay != null) {
            remove(_imageDisplay, true);
            _imageDisplay.destroy();
            _imageDisplay = null;
        }
    }
    
    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private override function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE:
                if (_eventMap.exists(MouseEvent.MOUSE_MOVE) == false) {
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.MOUSE_MOVE, listener);
                }
                
            case MouseEvent.MOUSE_OVER:
                if (_eventMap.exists(MouseEvent.MOUSE_OVER) == false) {
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.MOUSE_OVER, listener);
                }
                
            case MouseEvent.MOUSE_OUT:
                if (_eventMap.exists(MouseEvent.MOUSE_OUT) == false) {
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.MOUSE_OUT, listener);
                }

            case MouseEvent.MOUSE_DOWN:
                if (_eventMap.exists(MouseEvent.MOUSE_DOWN) == false) {
                    notifyMouseDown(true);
                    notifyMouseUp(true);
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.MOUSE_DOWN, listener);
                    if (hasTextInput()) {
                        getTextInput().onMouseDown = __onTextInputMouseEvent;
                    }
                }

            case MouseEvent.MOUSE_UP:
                if (_eventMap.exists(MouseEvent.MOUSE_UP) == false) {
                    notifyMouseDown(true);
                    notifyMouseUp(true);
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.MOUSE_UP, listener);
                    if (hasTextInput()) {
                        getTextInput().onMouseUp = __onTextInputMouseEvent;
                    }
                }
                
            case MouseEvent.MOUSE_WHEEL:
                if (_eventMap.exists(MouseEvent.MOUSE_WHEEL) == false) {
                    notifyMouseMove(true);
                    notifyMouseWheel(true);
                    _eventMap.set(MouseEvent.MOUSE_WHEEL, listener);
                }
                
            case MouseEvent.CLICK:
                if (_eventMap.exists(MouseEvent.CLICK) == false) {
                    notifyMouseDown(true);
                    notifyMouseUp(true);
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.CLICK, listener);
                    if (hasTextInput()) {
                        getTextInput().onClick = __onTextInputMouseEvent;
                    }
                }
                
            case MouseEvent.DBL_CLICK:
                if (_eventMap.exists(MouseEvent.DBL_CLICK) == false) {
                    notifyMouseDown(true);
                    notifyMouseUp(true);
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.DBL_CLICK, listener);
                }
                
            case MouseEvent.RIGHT_MOUSE_DOWN:
                if (_eventMap.exists(MouseEvent.RIGHT_MOUSE_DOWN) == false) {
                    notifyMouseDown(true);
                    notifyMouseUp(true);
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.RIGHT_MOUSE_DOWN, listener);
                }

            case MouseEvent.RIGHT_MOUSE_UP:
                if (_eventMap.exists(MouseEvent.RIGHT_MOUSE_UP) == false) {
                    notifyMouseDown(true);
                    notifyMouseUp(true);
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.RIGHT_MOUSE_UP, listener);
                }
                
            case MouseEvent.RIGHT_CLICK:
                if (_eventMap.exists(MouseEvent.RIGHT_CLICK) == false) {
                    notifyMouseDown(true);
                    notifyMouseUp(true);
                    notifyMouseMove(true);
                    _eventMap.set(MouseEvent.RIGHT_CLICK, listener);
                }
                
            case UIEvent.CHANGE:
                if (_eventMap.exists(UIEvent.CHANGE) == false) {
                    if (hasTextInput() == true) {
                        _eventMap.set(UIEvent.CHANGE, listener);
                        getTextInput().onChange = __onTextInputChange;
                    }
                }
        }
    }

    private override function unmapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE:
                _eventMap.remove(type);
                notifyMouseMove(false);
                
            case MouseEvent.MOUSE_OVER:
                _eventMap.remove(type);
                notifyMouseMove(false);
                
            case MouseEvent.MOUSE_OUT:
                _eventMap.remove(type);
                notifyMouseMove(false);

            case MouseEvent.MOUSE_DOWN:
                _eventMap.remove(type);
                notifyMouseDown(false);
                notifyMouseUp(false);
                notifyMouseMove(false);
                if (hasTextInput()) {
                    getTextInput().onMouseDown = null;
                }
                

            case MouseEvent.MOUSE_UP:
                _eventMap.remove(type);
                notifyMouseDown(false);
                notifyMouseUp(false);
                notifyMouseMove(false);
                if (hasTextInput()) {
                    getTextInput().onMouseUp = null;
                }
                
            case MouseEvent.MOUSE_WHEEL:
                _eventMap.remove(type);
                notifyMouseMove(false);
                notifyMouseWheel(false);
                
            case MouseEvent.CLICK:
                _eventMap.remove(type);
                notifyMouseDown(false);
                notifyMouseUp(false);
                notifyMouseMove(false);
                if (hasTextInput()) {
                    getTextInput().onClick = null;
                }
                
            case MouseEvent.DBL_CLICK:
                _eventMap.remove(type);
                notifyMouseDown(false);
                notifyMouseUp(false);
                notifyMouseMove(false);
                
            case MouseEvent.RIGHT_MOUSE_DOWN:
                _eventMap.remove(type);
                notifyMouseDown(false);
                notifyMouseUp(false);
                notifyMouseMove(false);

            case MouseEvent.RIGHT_MOUSE_UP:
                _eventMap.remove(type);
                notifyMouseDown(false);
                notifyMouseUp(false);
                notifyMouseMove(false);
                
            case MouseEvent.RIGHT_CLICK:
                _eventMap.remove(type);
                notifyMouseDown(false);
                notifyMouseUp(false);
                notifyMouseMove(false);
                
            case UIEvent.CHANGE:
                _eventMap.remove(type);
                if (hasTextInput() == true) {
                    getTextInput().onChange = null;
                }
        }
    }

    private var _counterNotifyMouseDown:Int = 0;
    private function notifyMouseDown(notify:Bool) {
        if (notify == true) {
            _counterNotifyMouseDown++;
        } else {
            _counterNotifyMouseDown--;
            if (_counterNotifyMouseDown < 0) {
                _counterNotifyMouseDown = 0;
            }
        }
        if (notify == true && _counterNotifyMouseDown == 1) {
            MouseHelper.notify(MouseEvent.MOUSE_DOWN, __onMouseDown);
        } else if (notify == false && _counterNotifyMouseDown == 0) {
            MouseHelper.remove(MouseEvent.MOUSE_DOWN, __onMouseDown);
        }
    }
    
    private var _counterNotifyMouseUp:Int = 0;
    private function notifyMouseUp(notify:Bool) {
        if (notify == true) {
            _counterNotifyMouseUp++;
        } else {
            _counterNotifyMouseUp--;
            if (_counterNotifyMouseUp < 0) {
                _counterNotifyMouseUp = 0;
            }
        }
        if (notify == true && _counterNotifyMouseUp == 1) {
            MouseHelper.notify(MouseEvent.MOUSE_UP, __onMouseUp);
        } else if (notify == false && _counterNotifyMouseUp == 0) {
            MouseHelper.remove(MouseEvent.MOUSE_UP, __onMouseUp);
        }
    }
    
    private var _counterNotifyMouseMove:Int = 0;
    private function notifyMouseMove(notify:Bool) {
        if (notify == true) {
            _counterNotifyMouseMove++;
        } else {
            _counterNotifyMouseMove--;
            if (_counterNotifyMouseMove < 0) {
                _counterNotifyMouseMove = 0;
            }
        }
        if (notify == true && _counterNotifyMouseMove == 1) {
            MouseHelper.notify(MouseEvent.MOUSE_MOVE, __onMouseMove);
        } else if (notify == false && _counterNotifyMouseMove == 0) {
            MouseHelper.remove(MouseEvent.MOUSE_MOVE, __onMouseMove);
        }
    }
    
    private var _counterNotifyMouseWheel:Int = 0;
    private function notifyMouseWheel(notify:Bool) {
        if (notify == true) {
            _counterNotifyMouseWheel++;
        } else {
            _counterNotifyMouseWheel--;
        }
        if (notify == true && _counterNotifyMouseWheel == 1) {
            MouseHelper.notify(MouseEvent.MOUSE_WHEEL, __onMouseWheel);
        } else if (notify == false && _counterNotifyMouseWheel == 0) {
            MouseHelper.remove(MouseEvent.MOUSE_WHEEL, __onMouseWheel);
        }
    }
    
    private function __onTextInputChange(event:TextInputEvent) {
        var fn:UIEvent->Void = _eventMap.get(UIEvent.CHANGE);
        if (fn != null) {
            fn(new UIEvent(UIEvent.CHANGE));
        }
    }
    
    private function __onTextInputMouseEvent(event:TextInputEvent) {
        var type = null;
        switch (event.type) {
            case openfl.events.MouseEvent.MOUSE_DOWN:
                type = MouseEvent.MOUSE_DOWN;
            case openfl.events.MouseEvent.MOUSE_UP:
                type = MouseEvent.MOUSE_UP;
            case openfl.events.MouseEvent.CLICK:
                type = MouseEvent.CLICK;
        }
        var fn:UIEvent->Void = _eventMap.get(type);
        if (fn != null) {
            var mouseEvent = new haxe.ui.events.MouseEvent(type);
            mouseEvent.screenX = event.stageX / Toolkit.scaleX;
            mouseEvent.screenY = event.stageY / Toolkit.scaleY;
            if (Platform.instance.isMobile) {
                mouseEvent.touchEvent = true;
            }
            fn(mouseEvent);
        }
    }
    
    private var _mouseOverFlag:Bool = false;
    private var _cursorSet:Bool = false;
    private function __onMouseMove(event:MouseEvent) {
        var x = event.screenX;
        var y = event.screenY;
        lastMouseX = x;
        lastMouseY = y;
        
        var hasMember = (this.state == StateHelper.currentState);

        if (Platform.instance.isMobile == false) {
            if (_mouseOverFlag == true) {
                if (hasMember == false) {
                    _mouseOverFlag = false;
                    var fn:UIEvent->Void = _eventMap.get(haxe.ui.events.MouseEvent.MOUSE_OUT);
                    if (fn != null) {
                        var mouseEvent = new haxe.ui.events.MouseEvent(haxe.ui.events.MouseEvent.MOUSE_OUT);
                        mouseEvent.screenX = x / Toolkit.scaleX;
                        mouseEvent.screenY = y / Toolkit.scaleY;
                        #if mobile
                        mouseEvent.touchEvent = true;
                        #end
                        fn(mouseEvent);
                        event.canceled = mouseEvent.canceled;
                    }
                    return;
                }
            }
            
            if (hasMember == false) {
                return;
            }

            var i = inBounds(x, y);
            if (i == true) {
                if (this.style != null && this.style.cursor != null) {
                    Screen.instance.setCursor(this.style.cursor, this.style.cursorOffsetX, this.style.cursorOffsetY);
                    _cursorSet = true;
                }

                var fn:UIEvent->Void = _eventMap.get(haxe.ui.events.MouseEvent.MOUSE_MOVE);
                if (fn != null) {
                    var mouseEvent = new haxe.ui.events.MouseEvent(haxe.ui.events.MouseEvent.MOUSE_MOVE);
                    mouseEvent.screenX = x / Toolkit.scaleX;
                    mouseEvent.screenY = y / Toolkit.scaleY;
                    #if mobile
                    mouseEvent.touchEvent = true;
                    #end
                    fn(mouseEvent);
                    event.canceled = mouseEvent.canceled;
                }
            }
            
            if (i == true && _mouseOverFlag == false) {
                if (isEventRelevant(getComponentsAtPoint(x, y, true), MouseEvent.MOUSE_OVER)) {
                    if (this.style != null && this.style.cursor != null) {
                        Screen.instance.setCursor(this.style.cursor, this.style.cursorOffsetX, this.style.cursorOffsetY);
                        _cursorSet = true;
                    }
    
                    _mouseOverFlag = true;
                    var fn:UIEvent->Void = _eventMap.get(haxe.ui.events.MouseEvent.MOUSE_OVER);
                    if (fn != null) {
                        var mouseEvent = new haxe.ui.events.MouseEvent(haxe.ui.events.MouseEvent.MOUSE_OVER);
                        mouseEvent.screenX = x / Toolkit.scaleX;
                        mouseEvent.screenY = y / Toolkit.scaleY;
                        #if mobile
                        mouseEvent.touchEvent = true;
                        #end
                        fn(mouseEvent);
                        event.canceled = mouseEvent.canceled;
                    }
                }
            } else if (i == false && _mouseOverFlag == true) {
                if (_cursorSet) {
                    Screen.instance.setCursor("default");
                    _cursorSet = false;
                }

                _mouseOverFlag = false;
                var fn:UIEvent->Void = _eventMap.get(haxe.ui.events.MouseEvent.MOUSE_OUT);
                if (fn != null) {
                    var mouseEvent = new haxe.ui.events.MouseEvent(haxe.ui.events.MouseEvent.MOUSE_OUT);
                    mouseEvent.screenX = x / Toolkit.scaleX;
                    mouseEvent.screenY = y / Toolkit.scaleY;
                    #if mobile
                    mouseEvent.touchEvent = true;
                    #end
                    fn(mouseEvent);
                    event.canceled = mouseEvent.canceled;
                }
            }
        }
    }

    private var _mouseDownFlag:Bool = false;
    private var _mouseDownButton:Int = -1;
    private function __onMouseDown(event:MouseEvent) {
        if (Platform.instance.isMobile == false) {
            if (_mouseOverFlag == false) {
                return;
            }
        }
        
        if (this.state != StateHelper.currentState) {
            return;
        }

        var button:Int = event.data;
        var x = event.screenX;
        var y = event.screenY;
        lastMouseX = x;
        lastMouseY = y;
        var i = inBounds(x, y);
        if (i == true && _mouseDownFlag == false) {
            /*
            if (hasComponentOver(cast this, x, y) == true) {
                return;
            }
            */
            if (isEventRelevant(getComponentsAtPoint(x, y, true), MouseEvent.MOUSE_DOWN)) {
                _mouseDownFlag = true;
                _mouseDownButton = button;
                var type = button == 0 ? haxe.ui.events.MouseEvent.MOUSE_DOWN: haxe.ui.events.MouseEvent.RIGHT_MOUSE_DOWN;
                var fn:UIEvent->Void = _eventMap.get(type);
                if (fn != null) {
                    var mouseEvent = new haxe.ui.events.MouseEvent(type);
                    mouseEvent.screenX = x / Toolkit.scaleX;
                    mouseEvent.screenY = y / Toolkit.scaleY;
                    if (Platform.instance.isMobile) {
                        mouseEvent.touchEvent = true;
                    }
                    fn(mouseEvent);
                    event.canceled = mouseEvent.canceled;
                }
            }
        }
    }

    private function __onMouseUp(event:MouseEvent) {
        if (Platform.instance.isMobile == false) {
            if (_mouseOverFlag == false) {
                //return;
            }
        }
        
        if (this.state != StateHelper.currentState) {
            return;
        }
        
        var button:Int = _mouseDownButton;
        var x = event.screenX;
        var y = event.screenY;
        
        lastMouseX = x;
        lastMouseY = y;
        var i = inBounds(x, y);
        if (i == true) {
            /*
            if (hasComponentOver(cast this, x, y) == true) {
                return;
            }
            */
            
            if (_mouseDownFlag == true) {
                var type = button == 0 ? haxe.ui.events.MouseEvent.CLICK: haxe.ui.events.MouseEvent.RIGHT_CLICK;
                var fn:UIEvent->Void = _eventMap.get(type);
                if (fn != null) {
                    var mouseEvent = new haxe.ui.events.MouseEvent(type);
                    mouseEvent.screenX = x / Toolkit.scaleX;
                    mouseEvent.screenY = y / Toolkit.scaleY;
                    if (Platform.instance.isMobile) {
                        mouseEvent.touchEvent = true;
                    }
                    fn(mouseEvent);
                    event.canceled = mouseEvent.canceled;
                }
                
                if (type == haxe.ui.events.MouseEvent.CLICK) {
                    _lastClickTimeDiff = Timer.stamp() - _lastClickTime;
                    _lastClickTime = Timer.stamp();
                    if (_lastClickTimeDiff >= 0.5) { // 0.5 seconds
                        _lastClickX = x;
                        _lastClickY = y;
                    }
                }
            }

            _mouseDownFlag = false;
            var type = button == 0 ? haxe.ui.events.MouseEvent.MOUSE_UP: haxe.ui.events.MouseEvent.RIGHT_MOUSE_UP;
            var fn:UIEvent->Void = _eventMap.get(type);
            if (fn != null) {
                var mouseEvent = new haxe.ui.events.MouseEvent(type);
                mouseEvent.screenX = x / Toolkit.scaleX;
                mouseEvent.screenY = y / Toolkit.scaleY;
                if (Platform.instance.isMobile) {
                    mouseEvent.touchEvent = true;
                }
                fn(mouseEvent);
                event.canceled = mouseEvent.canceled;
            }
        }
        _mouseDownFlag = false;
    }

    #if haxeui_dont_impose_base_class
    private function applyRootLayout(l:String) {
    }
    #end
    
    private function __onDoubleClick(event:MouseEvent) {
        if (this.state != StateHelper.currentState) {
            return;
        }
        
        var button:Int = _mouseDownButton;
        var x = event.screenX;
        var y = event.screenY;
        
        lastMouseX = x;
        lastMouseY = y;
        var i = inBounds(x, y);
        if (i == true && button == 0) {
            /*
            if (hasComponentOver(cast this, x, y) == true) {
                return;
            }
            */
            
            _mouseDownFlag = false;
            var mouseDelta:Float = MathUtil.distance(x, y, _lastClickX, _lastClickY);
            if (_lastClickTimeDiff < 0.5 && mouseDelta < 5) { // 0.5 seconds
                var type = haxe.ui.events.MouseEvent.DBL_CLICK;
                var fn:UIEvent->Void = _eventMap.get(type);
                if (fn != null) {
                    var mouseEvent = new haxe.ui.events.MouseEvent(type);
                    mouseEvent.screenX = x / Toolkit.scaleX;
                    mouseEvent.screenY = y / Toolkit.scaleY;
                    if (Platform.instance.isMobile) {
                        mouseEvent.touchEvent = true;
                    }
                    fn(mouseEvent);
                    event.canceled = mouseEvent.canceled;
                }
            }
        }
        _mouseDownFlag = false;
    }

    private function __onMouseWheel(event:MouseEvent) {
        if (this.state != StateHelper.currentState) {
            return;
        }
        
        var delta = event.delta;
        var fn = _eventMap.get(MouseEvent.MOUSE_WHEEL);

        if (fn == null) {
            return;
        }

        if (!inBounds(lastMouseX, lastMouseY)) {
            return;
        }

        var mouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL);
        mouseEvent.screenX = lastMouseX / Toolkit.scaleX;
        mouseEvent.screenY = lastMouseY / Toolkit.scaleY;
        mouseEvent.delta = Math.max(-1, Math.min(1, -delta));
        if (Platform.instance.isMobile) {
            mouseEvent.touchEvent = true;
        }
        fn(mouseEvent);
        event.canceled = mouseEvent.canceled;
    }
    
    private function isEventRelevant(children:Array<Component>, eventType:String):Bool {
        var relevant = false;
        for (c in children) {
            if (c == this) {
                relevant = true;
            }
            if (c.parentComponent == null) {
                break;
            }
        }
        
        return relevant;
    }
    
    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    public override function createTextDisplay(text:String = null):TextDisplay {
        if (_textDisplay == null) {
            super.createTextDisplay(text);
            _textDisplay.tf.visible = false;
            add(_textDisplay.tf);
            Toolkit.callLater(function() { // lets show it a frame later so its had a chance to reposition
                //_textDisplay.tf.visible = true;
                applyFilters(style);
            });
        }
        
        return _textDisplay;
    }
    
    public override function createTextInput(text:String = null):TextInput {
        if (_textInput == null) {
            super.createTextInput(text);
            _textInput.attach();
            _textInput.visible = false;
            _textInput.addToComponent(cast this);
            /*
            Toolkit.callLater(function() { // lets show it a frame later so its had a chance to reposition
                if (_textInput != null) {
                    _textInput.tf.visible = true;
                }
            });
            */
        }
        
        return _textInput;
    }
    //***********************************************************************************************************
    // Util
    //***********************************************************************************************************
    private function repositionChildren() {
        if (_surface != null) {
            _surface.x = this.screenX;
            _surface.y = this.screenY;
        }
        
        if (_textDisplay != null) {
            var offsetX = 2 / Toolkit.scaleX;
            var offsetY = 2 / Toolkit.scaleY;
            _textDisplay.tf.x = _surface.x + _textDisplay.left - offsetX;
            _textDisplay.tf.y = _surface.y + _textDisplay.top - offsetY;
        }
        
        if (_textInput != null) {
            var offsetX = 2 / Toolkit.scaleX;
            var offsetY = 2 / Toolkit.scaleY;
            _textInput.x = (_surface.x + _textInput.left - offsetX) * FlxG.scaleMode.scale.x;
            _textInput.y = (_surface.y + _textInput.top - offsetY) * FlxG.scaleMode.scale.y;
            _textInput.scaleX = FlxG.scaleMode.scale.x;
            _textInput.scaleY = FlxG.scaleMode.scale.y;
            _textInput.update();
        }
        
        if (_imageDisplay != null) {
            var offsetX = 0;
            var offsetY = 0;
            _imageDisplay.x = _surface.x + _imageDisplay.left - offsetX;
            _imageDisplay.y = _surface.y + _imageDisplay.top - offsetY;
        }
        
        if (_unsolicitedMembers != null) {
            for (m in _unsolicitedMembers) {
                m.sprite.x = m.originalX + this.screenX;
                m.sprite.y = m.originalY + this.screenY;
            }
        }
    }
    
    private function isUnsolicitedMember(m:FlxSprite) {
        if (m == _surface) {
            return false;
        }
        
        if (_textDisplay != null && m == _textDisplay.tf) {
            return false;
        }
        
        if (m == _imageDisplay) {
            return false;
        }
        
        return !(m is Component);
    }
    
    private function hasComponentOver(ref:Component, x:Float, y:Float):Bool {
        var array:Array<Component> = getComponentsAtPoint(x, y);
        if (array.length == 0) {
            return false;
        }

        return !hasChildRecursive(cast ref, cast array[array.length - 1]);
    }

    private function getComponentsAtPoint(x:Float, y:Float, reverse:Bool = false):Array<Component> {
        var array:Array<Component> = new Array<Component>();
        for (r in Screen.instance.rootComponents) {
            findChildrenAtPoint(r, x, y, array);
        }
        
        if (reverse == true) {
            array.reverse();
        }
        
        return array;
    }

    private function findChildrenAtPoint(child:Component, x:Float, y:Float, array:Array<Component>) {
        if (child.inBounds(x, y) == true) {
            array.push(child);
        }
        for (c in child.childComponents) {
            findChildrenAtPoint(c, x, y, array);
        }
    }

    public function hasChildRecursive(parent:Component, child:Component):Bool {
        if (parent == child) {
            return true;
        }
        var r = false;
        for (t in parent.childComponents) {
            if (t == child) {
                r = true;
                break;
            }

            r = hasChildRecursive(t, child);
            if (r == true) {
                break;
            }
        }

        return r;
    }
    
    //***********************************************************************************************************
    // Flixel overrides
    //***********************************************************************************************************

    private var _updates:Float = 0;
    public override function update(elapsed:Float) {
        if (_destroyed) {
            super.update(elapsed);
            return;
        }
        if (_destroy == true) {
            destroyInternal();
            super.update(elapsed);
            return;
        }
        
        clearCaches();
        repositionChildren();
        applyClipRect();

        _updates++;
        if (_updates == 1) {
            if (asComponent.hidden == false) {
                applyVisibility(true);
            } else {
                applyVisibility(false);
            }
        }
        
        super.update(elapsed);
    }

    private function applyClipRect() {
        if (this.componentClipRect != null) {
            var value = this.componentClipRect;
            value.top = Std.int(value.top);
            value.left = Std.int(value.left);
            if (parentComponent != null) {
                var rect = FlxRect.get((value.left * Toolkit.scaleX) + _surface.x - parentComponent.x,
                                    (value.top * Toolkit.scaleY) + _surface.y - parentComponent.y,
                                    (value.width * Toolkit.scaleX), (value.height * Toolkit.scaleY));
                clipRect = rect;
                rect.put();
            } else { // top-level (root) components can also clip (Absolute auto clips via a css style), but this means they wont have a parentComponent set, lets handle them differently
                var rect = FlxRect.get(_surface.x, _surface.y, value.width, value.height);
                clipRect = rect;
                rect.put();
            }
        }
    }
    
    // these functions (applyAddInternal / applyRemoveInternal) are called when a component is added / removed
    // from the screen - the main (only) reason this is important is because of textinputs:
    // textinputs are using openfl textfields, which means they are effectively floating over the top of the 
    // application, this means that when things are removed from the screen (and not destroyed) it can leave them
    // behind
    private function applyAddInternal() {
        if (!TextInputImpl.USE_ON_ADDED) {
            return;
        }

        if (hasTextInput() && asComponent.hidden == false) {
            getTextInput().visible = true;
        }
        for (c in childComponents) {
            c.applyAddInternal();
        }
    }

    private function applyRemoveInternal() {
        if (!TextInputImpl.USE_ON_REMOVED) {
            return;
        }

        if (hasTextInput()) {
            getTextInput().visible = false;
        }
        for (c in childComponents) {
            c.applyRemoveInternal();
        }
    }

    private var _destroyed:Bool = false;
    private function destroyInternal() {
        if (!_allowDestroy) {
            return;
        }
        if (_surface != null) {
            _surface.destroy();
            _surface = null;
        }
        
        if (_textDisplay != null) {
            _textDisplay.tf.destroy();
            _textDisplay = null;
        }
        
        if (_textInput != null) {
            _textInput.destroy(cast this);
            _textInput = null;
        }
        
        if (_imageDisplay != null) {
            _imageDisplay.destroy();
            _imageDisplay = null;
        }
        
        if (_unsolicitedMembers != null) {
            _unsolicitedMembers = null;
        }
        
        _destroy = false;
        _destroyed = true;
        super.destroy();
    }
    
    private var _allowDestroy:Bool = true;
    public override function destroy():Void {
        if (!_allowDestroy) {
            return;
        }

        if (parentComponent != null) {
            if (parentComponent.getComponentIndex(cast this) != -1) {
                parentComponent.removeComponent(cast this);
                return;
            }
        } else {
            Screen.instance.removeComponent(cast this);
        }

        _destroy = true;
    }
    
    private override function set_x(value:Float):Float {
        var r = super.set_x(value);
        if (this.parentComponent == null) {
            this.left = value;
        }
        return r;
    }
    
    private override function set_y(value:Float):Float {
        var r = super.set_y(value);
        if (this.parentComponent == null) {
            this.top = value;
        }
        return r;
    }
}