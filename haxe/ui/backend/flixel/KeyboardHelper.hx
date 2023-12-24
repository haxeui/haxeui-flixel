package haxe.ui.backend.flixel;

import flixel.FlxG;
import haxe.ui.events.KeyboardEvent;

typedef KeyboardCallback = {
    var fn:KeyboardEvent->Void;
    var priority:Int;
}

class KeyboardHelper {
    private static var _hasOnKeyDown:Bool = false;
    private static var _hasOnKeyUp:Bool = false;

    private static var _callbacks:Map<String, Array<KeyboardCallback>> = new Map<String, Array<KeyboardCallback>>();
    
    public static function notify(event:String, callback:KeyboardEvent->Void, priority:Int = 5) {
        switch (event) {
            case KeyboardEvent.KEY_DOWN:
                if (_hasOnKeyDown == false) {
                    FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, onKeyDown);
                    _hasOnKeyDown = true;
                }
            case KeyboardEvent.KEY_UP:
                if (_hasOnKeyUp == false) {
                    FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, onKeyUp);
                    _hasOnKeyUp = true;
                }
        }

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
                
                switch (event) {
                    case KeyboardEvent.KEY_DOWN:
                        if (_hasOnKeyDown == true) {
                            FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, onKeyDown);
                            _hasOnKeyDown = false;
                        }
                    case KeyboardEvent.KEY_UP:
                        if (_hasOnKeyUp == true) {
                            FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_UP, onKeyUp);
                            _hasOnKeyUp = false;
                        }
                }
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
        var list = _callbacks.get(type);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();

        var event = new KeyboardEvent(type);
        event.keyCode = e.keyCode;
        event.altKey = e.altKey;
        event.ctrlKey = e.ctrlKey;
        event.shiftKey = e.shiftKey;

        for (l in list) {
            l.fn(event);
            if (event.canceled == true) {
                break;
            }
        }
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