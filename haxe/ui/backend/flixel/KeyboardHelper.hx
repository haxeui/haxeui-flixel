package haxe.ui.backend.flixel;

import flixel.FlxG;
import haxe.ui.core.Component;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.focus.FocusManager;

@:structInit
class KeyboardCallback {
    public var fn:KeyboardEvent->Void;
    public var priority:Int;
}

class KeyboardHelper {
    private static var _initialized = false;
    private static var _callbacks:Map<String, Array<KeyboardCallback>> = new Map<String, Array<KeyboardCallback>>();

    public static function init() {
        if (_initialized == true) {
            return;
        }
        
        _initialized = true;

        FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, onKeyDown);
        FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, onKeyUp);
    }
    
    public static function notify(event:String, callback:KeyboardEvent->Void, priority:Int = 5) {
        var list = _callbacks.get(event);
        if (list == null) {
            list = new Array<KeyboardCallback>();
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

    public static function remove(event:String, callback:KeyboardEvent->Void) {
        var list = _callbacks.get(event);
        if (list != null) {
            removeCallback(list, callback);
            if (list.length == 0) {
                _callbacks.remove(event);
            }
        }
    }

    private static function onKeyDown(e:openfl.events.KeyboardEvent) {
        dispatchEvent(KeyboardEvent.KEY_DOWN, e);
    }

    private static function onKeyUp(e:openfl.events.KeyboardEvent) {
        dispatchEvent(KeyboardEvent.KEY_UP, e);
    }

    private static function dispatchEvent(type:String, e:openfl.events.KeyboardEvent) {
        var event = new KeyboardEvent(type);
        event.keyCode = e.keyCode;
        event.altKey = e.altKey;
        event.ctrlKey = e.ctrlKey;
        event.shiftKey = e.shiftKey;
        
        var target = getTarget();
        // recreate a bubbling effect, so components will pass events onto their parents
        // can't use the `bubble` property as it causes a crash when `target` isn't the expected result, for example, on ListView.onRendererClick
        while (target != null) {
            if (target.hasEvent(event.type)) {
                target.dispatch(event);
                if (event.canceled == true) {
                    return;
                }
            }
            target = target.parentComponent;
        }

        var list = _callbacks.get(type);
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

    private static function getTarget():Component {
        var target:Component = cast FocusManager.instance.focus;
        if (target != null && target.state == StateHelper.currentState) {
            return target;
        }
        return null;
    }

    private static function hasCallback(list:Array<KeyboardCallback>, fn:KeyboardEvent->Void):Bool {
        var has = false;
        for (item in list) {
            if (item.fn == fn) {
                has = true;
                break;
            }
        }
        return has;
    }

    private static function removeCallback(list:Array<KeyboardCallback>, fn:KeyboardEvent->Void) {
        var itemToRemove:KeyboardCallback = null;
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