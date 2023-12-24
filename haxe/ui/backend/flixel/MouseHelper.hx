package haxe.ui.backend.flixel;

import flixel.FlxG;
import haxe.ui.events.MouseEvent;

typedef MouseCallback = {
    var fn:MouseEvent->Void;
    var priority:Int;
}

class MouseHelper {
    public static var currentMouseX:Float = 0;
    public static var currentMouseY:Float = 0;
    
    private static var _hasOnMouseDown:Bool = false;
    private static var _hasOnMouseUp:Bool = false;
    private static var _hasOnMouseMove:Bool = false;
    private static var _hasOnMouseWheel:Bool = false;
    
    private static var _callbacks:Map<String, Array<MouseCallback>> = new Map<String, Array<MouseCallback>>();
    
    public static function notify(event:String, callback:MouseEvent->Void, priority:Int = 5) {
        switch (event) {
            case MouseEvent.MOUSE_DOWN:
                if (_hasOnMouseDown == false) {
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_DOWN, onMouseDown);
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
                    _hasOnMouseDown = true;
                }
            case MouseEvent.MOUSE_UP:
                if (_hasOnMouseUp == false) {
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_UP, onMouseUp);
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
                    _hasOnMouseUp = true;
                    FlxG.signals.preStateSwitch.add(onPreStateSwitched);
                }
            case MouseEvent.MOUSE_MOVE:
                if (_hasOnMouseMove == false) {
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_MOVE, onMouseMove);
                    _hasOnMouseMove = true;
                }
            case MouseEvent.MOUSE_WHEEL:
                if (_hasOnMouseWheel == false) {
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_WHEEL, onMouseWheel);
                    _hasOnMouseWheel = true;
                }
        }
        
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
                
                switch (event) {
                    case MouseEvent.MOUSE_DOWN:
                        if (_hasOnMouseDown == true) {
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_DOWN, onMouseDown);
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.RIGHT_MOUSE_DOWN, onMouseDown);
                            _hasOnMouseDown = false;
                        }
                    case MouseEvent.MOUSE_UP:
                        if (_hasOnMouseUp == true) {
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_UP, onMouseUp);
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
                            _hasOnMouseUp = false;
                            FlxG.signals.preStateSwitch.remove(onPreStateSwitched);
                        }
                    case MouseEvent.MOUSE_MOVE:
                        if (_hasOnMouseMove == true) {
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_MOVE, onMouseMove);
                            _hasOnMouseMove = false;
                        }
                    case MouseEvent.MOUSE_WHEEL:
                        if (_hasOnMouseWheel == true) {
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_WHEEL, onMouseWheel);
                            _hasOnMouseWheel = false;
                        }
                }
            }
        }
    }
    
    private static function onPreStateSwitched() {
        // simulate mouse events when states switch to mop up any visual styles
        var e = new openfl.events.MouseEvent(openfl.events.MouseEvent.MOUSE_DOWN);
        e.stageX = currentMouseX;
        e.stageY = currentMouseY;
        e.buttonDown = false;
        onMouseUp(e);

        var e = new openfl.events.MouseEvent(openfl.events.MouseEvent.MOUSE_MOVE);
        e.stageX = currentMouseX;
        e.stageY = currentMouseY;
        e.buttonDown = false;
        onMouseMove(e);
    }
    
    private static function onMouseDown(e:openfl.events.MouseEvent) {
        if (e != null) {
            currentMouseX = e.stageX;
            currentMouseY = e.stageY;
        }
        
        var list = _callbacks.get(MouseEvent.MOUSE_DOWN);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        
        var event = new MouseEvent(MouseEvent.MOUSE_DOWN);
        if (e != null) {
            event.screenX = (e.stageX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * initialZoom());
            event.screenY = (e.stageY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * initialZoom());
        } else {
            event.screenX = (currentMouseX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * initialZoom());
            event.screenY = (currentMouseY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * initialZoom());
        }

        event.data = -1;
        if (e.type == openfl.events.MouseEvent.MOUSE_DOWN) {
            event.data = 0;
        } else if (e.type == openfl.events.MouseEvent.RIGHT_MOUSE_DOWN) {
            event.data = 1;
        }

        for (l in list) {
            l.fn(event);
            if (event.canceled == true) {
                break;
            }
        }
    }
    
    private static function onMouseUp(e:openfl.events.MouseEvent) {
        if (e != null) {
            currentMouseX = e.stageX;
            currentMouseY = e.stageY;
        }
        
        var list = _callbacks.get(MouseEvent.MOUSE_UP);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        
        var event = new MouseEvent(MouseEvent.MOUSE_UP);
        if (e != null) {
            event.screenX = (e.stageX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * initialZoom());
            event.screenY = (e.stageY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * initialZoom());
        } else {
            event.screenX = (currentMouseX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * initialZoom());
            event.screenY = (currentMouseY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * initialZoom());
        }

        event.data = -1;
        if (e.type == openfl.events.MouseEvent.MOUSE_UP) {
            event.data = 0;
        } else if (e.type == openfl.events.MouseEvent.RIGHT_MOUSE_UP) {
            event.data = 1;
        }

        for (l in list) {
            l.fn(event);
            if (event.canceled == true) {
                break;
            }
        }
    }
    
    private static function onMouseMove(e:openfl.events.MouseEvent) {
        if (e != null) {
            currentMouseX = e.stageX;
            currentMouseY = e.stageY;
        }
        
        var list = _callbacks.get(MouseEvent.MOUSE_MOVE);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        var event = new MouseEvent(MouseEvent.MOUSE_MOVE);
        if (e != null) {
            event.screenX = (e.stageX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * initialZoom());
            event.screenY = (e.stageY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * initialZoom());
        } else {
            event.screenX = (currentMouseX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * initialZoom());
            event.screenY = (currentMouseY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * initialZoom());
        }

        for (l in list) {
            l.fn(event);
            if (event.canceled == true) {
                break;
            }
        }
    }
    
    private static function onMouseWheel(e:openfl.events.MouseEvent) {
        var list = _callbacks.get(MouseEvent.MOUSE_WHEEL);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        
        var event = new MouseEvent(MouseEvent.MOUSE_WHEEL);
        event.delta = -e.delta;
        for (l in list) {
            l.fn(event);
            if (event.canceled == true) {
                break;
            }
        }
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