package haxe.ui.backend.flixel;
import flixel.FlxG;
import haxe.ui.events.MouseEvent;

class MouseHelper {
    public static var currentMouseX:Float = 0;
    public static var currentMouseY:Float = 0;
    
    private static var _hasOnMouseDown:Bool = false;
    private static var _hasOnMouseUp:Bool = false;
    private static var _hasOnMouseMove:Bool = false;
    private static var _hasOnMouseWheel:Bool = false;
    
    private static var _callbacks:Map<String, Array<MouseEvent->Void>> = new Map<String, Array<MouseEvent->Void>>();
    
    private static var _inputManager:InputManager = null;
    
    public static function notify(event:String, callback:MouseEvent->Void) {
        switch (event) {
            case MouseEvent.MOUSE_DOWN:
                if (_hasOnMouseDown == false) {
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_DOWN, onMouseDown);
                    _hasOnMouseDown = true;
                }
            case MouseEvent.MOUSE_UP:
                if (_hasOnMouseUp == false) {
                    FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_UP, onMouseUp);
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
            list = new Array<MouseEvent->Void>();
            _callbacks.set(event, list);
        }
        
        list.push(callback);
        
        if (_inputManager == null) {
            _inputManager = new InputManager();
            _inputManager.onResetCb = onPreStateSwitched;
            FlxG.inputs.add(_inputManager);
        }
    }
    
    public static function remove(event:String, callback:MouseEvent->Void) {
        var list = _callbacks.get(event);
        if (list != null) {
            list.remove(callback);
            if (list.length == 0) {
                _callbacks.remove(event);
                
                switch (event) {
                    case MouseEvent.MOUSE_DOWN:
                        if (_hasOnMouseDown == true) {
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_DOWN, onMouseDown);
                            _hasOnMouseDown = false;
                        }
                    case MouseEvent.MOUSE_UP:
                        if (_hasOnMouseUp == true) {
                            FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_UP, onMouseUp);
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
        onMouseUp(null);
        onMouseMove(null);
    }
    
    private static function onMouseDown(e:openfl.events.MouseEvent) {
        var list = _callbacks.get(MouseEvent.MOUSE_DOWN);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        
        var event = new MouseEvent(MouseEvent.MOUSE_DOWN);
        if (e != null) {
            event.screenX = (e.stageX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * FlxG.initialZoom);
            event.screenY = (e.stageY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * FlxG.initialZoom);
        } else {
            event.screenX = (currentMouseX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * FlxG.initialZoom);
            event.screenY = (currentMouseY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * FlxG.initialZoom);
        }
        event.data = buttonPressed;
        for (l in list) {
            l(event);
        }
    }
    
    private static function onMouseUp(e:openfl.events.MouseEvent) {
        var list = _callbacks.get(MouseEvent.MOUSE_UP);
        if (list == null || list.length == 0) {
            return;
        }
        
        list = list.copy();
        
        var event = new MouseEvent(MouseEvent.MOUSE_UP);
        if (e != null) {
            event.screenX = (e.stageX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * FlxG.initialZoom);
            event.screenY = (e.stageY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * FlxG.initialZoom);
        } else {
            event.screenX = (currentMouseX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * FlxG.initialZoom);
            event.screenY = (currentMouseY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * FlxG.initialZoom);
        }
        event.data = buttonPressed;
        for (l in list) {
            l(event);
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
            event.screenX = (e.stageX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * FlxG.initialZoom);
            event.screenY = (e.stageY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * FlxG.initialZoom);
        } else {
            event.screenX = (currentMouseX - FlxG.scaleMode.offset.x) / (FlxG.scaleMode.scale.x * FlxG.initialZoom);
            event.screenY = (currentMouseY - FlxG.scaleMode.offset.y) / (FlxG.scaleMode.scale.y * FlxG.initialZoom);
        }
        for (l in list) {
            l(event);
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
            l(event);
        }
    }
    
    private static var buttonPressed(get, null):Int;
    private static function get_buttonPressed():Int {
        var n = -1;
        if (FlxG.mouse.pressed == true) {
            n = 0;
        } else if (FlxG.mouse.pressedRight == true) {
            n = 1;
        }
        return n;
    }
}