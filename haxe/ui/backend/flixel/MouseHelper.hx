package haxe.ui.backend.flixel;

import flixel.FlxG;
import haxe.ui.core.Component;
import haxe.ui.core.Platform;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;

@:structInit
class MouseCallback {
    public var fn:MouseEvent->Void;
    public var priority:Int;
}

class MouseHelper {
    public static var currentMouseX:Float = 0;
    public static var currentMouseY:Float = 0;
    public static var currentWorldX:Float = 0;
    public static var currentWorldY:Float = 0;
    
    private static var _initialized = false;
    private static var _callbacks:Map<String, Array<MouseCallback>> = new Map<String, Array<MouseCallback>>();

    private static var _mouseDownLeft:Dynamic;
    private static var _mouseDownMiddle:Dynamic;
    private static var _mouseDownRight:Dynamic;
    private static var _lastClickTarget:Dynamic;
    private static var _lastClickTime:Float;
    private static var _mouseOverTarget:Dynamic;

    public static function init() {
        if (_initialized == true) {
            return;
        }
        
        _initialized = true;

        FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_DOWN, onMouseDown);
        FlxG.stage.addEventListener(openfl.events.MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
        FlxG.stage.addEventListener(openfl.events.MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);

        FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_UP, onMouseUp);
        FlxG.stage.addEventListener(openfl.events.MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
        FlxG.stage.addEventListener(openfl.events.MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);

        FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_MOVE, onMouseMove);

        FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_WHEEL, onMouseWheel);

        FlxG.signals.preStateSwitch.add(onPreStateSwitched);
    }
    
    public static function notify(event:String, callback:MouseEvent->Void, priority:Int = 5) {
        var list = _callbacks.get(event);
        if (list == null) {
            list = new Array<MouseCallback>();
            _callbacks.set(event, list);
        }
        
        if (!hasCallback(list, callback)) {
            list.insert(0, {
                fn: callback,
                priority: priority
            });

            list.sort(function(a, b) {
                return a.priority - b.priority;
            });
        }
    }
    
    public static function remove(event:String, callback:MouseEvent->Void) {
        var list = _callbacks.get(event);
        if (list != null) {
            removeCallback(list, callback);
            if (list.length == 0) {
                _callbacks.remove(event);
            }
        }
    }
    
    private static function onPreStateSwitched() {
        // simulate mouse events when states switch to mop up any visual styles
        onMouse(MouseEvent.MOUSE_UP, currentMouseX, currentMouseY);
        onMouse(MouseEvent.MOUSE_MOVE, currentMouseX, currentMouseY);
    }
    
    private static function onMouseDown(e:openfl.events.MouseEvent) {
        var type = switch (e.type) {
            case openfl.events.MouseEvent.MIDDLE_MOUSE_DOWN: MouseEvent.MIDDLE_MOUSE_DOWN;
            case openfl.events.MouseEvent.RIGHT_MOUSE_DOWN: MouseEvent.RIGHT_MOUSE_DOWN;
            default: MouseEvent.MOUSE_DOWN;
        }
        onMouse(type, e.stageX, e.stageY, e.buttonDown, e.ctrlKey, e.shiftKey);
    }
    
    private static function onMouseUp(e:openfl.events.MouseEvent) {
        var type = switch (e.type) {
            case openfl.events.MouseEvent.MIDDLE_MOUSE_UP: MouseEvent.MIDDLE_MOUSE_UP;
            case openfl.events.MouseEvent.RIGHT_MOUSE_UP: MouseEvent.RIGHT_MOUSE_UP;
            default: MouseEvent.MOUSE_UP;
        }
        onMouse(type, e.stageX, e.stageY, e.buttonDown, e.ctrlKey, e.shiftKey);
    }
    
    private static function onMouseMove(e:openfl.events.MouseEvent) {
        onMouse(MouseEvent.MOUSE_MOVE, e.stageX, e.stageY, e.buttonDown, e.ctrlKey, e.shiftKey);
    }
    
    private static function onMouseWheel(e:openfl.events.MouseEvent) {
        var event = createEvent(MouseEvent.MOUSE_WHEEL, e.buttonDown, e.ctrlKey, e.shiftKey);
        event.delta = Math.max(-1, Math.min(1, e.delta));

        var target:Dynamic = getTarget(currentWorldX, currentWorldY);

        dispatchEvent(event, target);
    }

    private static function onMouse(type:String, x:Float, y:Float, buttonDown:Bool = false, ctrlKey:Bool = false, shiftKey:Bool = false) {
        if (currentMouseX != x) {
            currentMouseX = x;
            currentWorldX = (currentMouseX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * initialZoom());
        }
        if (currentMouseY != y) {
            currentMouseY = y;
            currentWorldY = (currentMouseY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * initialZoom());
        }

        var target:Dynamic = getTarget(currentWorldX, currentWorldY);

        var clickType:String = null;
        switch (type) {
            case MouseEvent.MOUSE_DOWN:
                _mouseDownLeft = target;

            case MouseEvent.MIDDLE_MOUSE_DOWN:
                _mouseDownMiddle = target;

            case MouseEvent.RIGHT_MOUSE_DOWN:
                _mouseDownRight = target;

            case MouseEvent.MOUSE_UP:
                if (_mouseDownLeft == target) {
                    clickType = MouseEvent.CLICK;
                }
                _mouseDownLeft = null;

            case MouseEvent.MIDDLE_MOUSE_UP:
                if (_mouseDownMiddle == target) {
                    clickType = MouseEvent.MIDDLE_CLICK;
                }
                _mouseDownMiddle = null;

            case MouseEvent.RIGHT_MOUSE_UP:
                if (_mouseDownRight == target) {
                    clickType = MouseEvent.RIGHT_CLICK;
                }
                _mouseDownRight = null;
        }

        dispatchEventType(type, buttonDown, ctrlKey, shiftKey, target);

        if (clickType != null) {
            dispatchEventType(clickType, buttonDown, ctrlKey, shiftKey, target);
            
            if (type == MouseEvent.MOUSE_UP) {
                var currentTime = Timer.stamp();
                if (currentTime - _lastClickTime < 0.5 && target == _lastClickTarget) {
                    dispatchEventType(MouseEvent.DBL_CLICK, buttonDown, ctrlKey, shiftKey, target);
                    _lastClickTime = 0;
                    _lastClickTarget = null;
                } else {
                    _lastClickTarget = target;
                    _lastClickTime = currentTime;
                }
            }
        }

        if (target != _mouseOverTarget) {
            if (_mouseOverTarget != null) {
                if ((_mouseOverTarget is Component)) {
                    Screen.instance.setCursor("default");
                }
                dispatchEventType(MouseEvent.MOUSE_OUT, buttonDown, ctrlKey, shiftKey, _mouseOverTarget);
            }
            if ((target is Component)) {
                var c:Component = target;
                if (c.style != null && c.style.cursor != null) {
                    Screen.instance.setCursor(c.style.cursor, c.style.cursorOffsetX, c.style.cursorOffsetY);
                }
            }
            dispatchEventType(MouseEvent.MOUSE_OVER, buttonDown, ctrlKey, shiftKey, target);
            _mouseOverTarget = target;
        }
    }

    private static function dispatchEventType(type:String, buttonDown:Bool, ctrlKey:Bool, shiftKey:Bool, target:Dynamic) {
        var event = createEvent(type, buttonDown, ctrlKey, shiftKey);
        dispatchEvent(event, target);
    }

    private static function dispatchEvent(event:MouseEvent, target:Dynamic) {
        if ((target is Component)) {
            var c:Component = cast target;
            // recreate a bubbling effect, so components will pass events onto their parents
            // can't use the `bubble` property as it causes a crash when `target` isn't the expected result, for example, on ListView.onRendererClick
            while (c != null) {
                if (c.hasEvent(event.type)) {
                    c.dispatch(event);
                    if (event.canceled == true) {
                        return;
                    }
                }
                c = c.parentComponent;
            }
        }
        
        var list = _callbacks.get(event.type);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();

        for (l in list) {
            l.fn(event);
            if (event.canceled == true) {
                break;
            }
        }
    }

    private static function createEvent(type:String, buttonDown:Bool, ctrlKey:Bool, shiftKey:Bool):MouseEvent {
        var event = new MouseEvent(type);
        event.screenX = currentWorldX / Toolkit.scaleX;
        event.screenY = currentWorldY / Toolkit.scaleY;
        event.buttonDown = buttonDown;
        event.touchEvent = Platform.instance.isMobile;
        event.ctrlKey = ctrlKey;
        event.shiftKey = shiftKey;
        return event;
    }

    private static function getTarget(x:Float, y:Float):Dynamic {
        var target:Dynamic = null;
        var components = Screen.instance.findComponentsUnderPoint(x, y);
        if (components.length > 0 && components[components.length - 1].state == StateHelper.currentState) {
            target = components[components.length - 1];
        }
        if (target == null) target = Screen.instance;
        return target;
    }
    
    private static inline function initialZoom():Float {
        #if (flixel <= "4.11.0") // FlxG.initialZoom removed in later versions of flixel
        
        return FlxG.initialZoom;
        
        #else
        
        return 1;
        
        #end
    }
    
    private static function hasCallback(list:Array<MouseCallback>, fn:MouseEvent->Void):Bool {
        var has = false;
        for (item in list) {
            if (item.fn == fn) {
                has = true;
                break;
            }
        }
        return has;
    }
    
    private static function removeCallback(list:Array<MouseCallback>, fn:MouseEvent->Void) {
        var itemToRemove:MouseCallback = null;
        for (item in list) {
            if (item.fn == fn) {
                itemToRemove = item;
                break;
            }
        }
        if (itemToRemove != null) {
            list.remove(itemToRemove);
        }
    }
}