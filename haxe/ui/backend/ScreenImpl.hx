package haxe.ui.backend;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import haxe.ui.backend.flixel.MouseHelper;
import haxe.ui.backend.flixel.StateHelper;
import haxe.ui.core.Component;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import lime.system.System;
import openfl.Lib;

@:access(haxe.ui.backend.ComponentImpl)
class ScreenImpl extends ScreenBase {
    private var _mapping:Map<String, UIEvent->Void>;
    
    #if (flixel < "4.9.0") // subStateOpened / subStateClosed added in 4.9.0
    private static var _inputManager:haxe.ui.backend.flixel.InputManager = null;
    #end
    
    public function new() {
        _mapping = new Map<String, UIEvent->Void>();

        #if (flixel < "4.9.0") // subStateOpened / subStateClosed added in 4.9.0
        
        if (_inputManager == null) {
            _inputManager = new haxe.ui.backend.flixel.InputManager();
            _inputManager.onResetCb = onReset;
            FlxG.inputs.add(_inputManager);
        }
        
        #end
        
        FlxG.signals.postGameStart.add(onPostGameStart);
        FlxG.signals.postStateSwitch.add(onPostStateSwitch);
        FlxG.signals.preStateCreate.add(onPreStateCreate);
        onPostStateSwitch();
        
        addResizeHandler();
    }

    private function onPreStateCreate(state:flixel.FlxState) {
        state.memberAdded.add(onMemberAdded);
        checkMembers(state);
        state.memberRemoved.add(onMemberRemoved);
    }
    
    #if (flixel < "4.9.0") // subStateOpened / subStateClosed added in 4.9.0
    
    private function onReset() {
        if (FlxG.state != null && FlxG.state.subState != null) {
            var cachedSubStateOpenedCallback = FlxG.state.subState.openCallback;
            FlxG.state.subState.openCallback = function() {
                onMemberAdded(FlxG.state.subState);
                if (cachedSubStateOpenedCallback != null) {
                    cachedSubStateOpenedCallback();
                }
            }
        }
    }
    
    #end
    
    private function onPostGameStart() {
        onPostStateSwitch();
    }
    
    private function onPostStateSwitch() {
        if (FlxG.game == null) {
            return;
        }
        rootComponents = [];
        
        #if (flixel >= "4.9.0") // subStateOpened / subStateClosed added in 4.9.0
        FlxG.state.subStateOpened.add(onMemberAdded);
        #end
        
        FlxG.state.memberAdded.add(onMemberAdded);
        checkMembers(FlxG.state);
        
        FlxG.state.memberRemoved.add(onMemberRemoved);

		#if (!FLX_NO_MOUSE && !haxeui_no_mouse_reset)
        var screen = cast(this, haxe.ui.core.Screen);
        screen.registerEvent(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
            if (screen.hasSolidComponentUnderPoint(e.screenX, e.screenY)) {
                FlxG.mouse.reset();
            }
        });
        #end
    }

    private function onMemberAdded(m:FlxBasic) {
        if ((m is Component) && rootComponents.indexOf(cast(m, Component)) == -1) {
            var c = cast(m, Component);
            if (c.percentWidth > 0) {
                c.width = (this.width * c.percentWidth) / 100;
            }
            if (c.percentHeight > 0) {
                c.height = (this.height * c.percentHeight) / 100;
            }
            rootComponents.push(c);
            c.recursiveReady();
            c.syncComponentValidation();
        } else if ((m is FlxTypedGroup)) {
            var group:FlxTypedGroup<FlxBasic> = cast m;
            checkMembers(group);
        }
    }

    private function onMemberRemoved(m:FlxBasic) {
        if ((m is Component) && rootComponents.indexOf(cast(m, Component)) != -1) {
            @:privateAccess var isDisposed = cast(m, Component)._isDisposed;
            removeComponent(cast m, isDisposed);
        }
    }

    private function checkMembers(state:FlxTypedGroup<FlxBasic>) {
        var found = false; // we only want top level components
        for (m in state.members) {
            if ((m is Component) && rootComponents.indexOf(cast(m, Component)) == -1) {
                var c = cast(m, Component);
                if (c.percentWidth > 0) {
                    c.width = (this.width * c.percentWidth) / 100;
                }
                if (c.percentHeight > 0) {
                    c.height = (this.height * c.percentHeight) / 100;
                }
                rootComponents.push(c);
                c.recursiveReady();
                c.syncComponentValidation();
                found = true;
            } else if ((m is FlxTypedGroup)) {
                var group:FlxTypedGroup<FlxBasic> = cast m;
                group.memberAdded.addOnce(onMemberAdded);
                if (checkMembers(group) == true) {
                    found = true;
                    break;
                }
            } else if ((m is FlxTypedSpriteGroup)) {
                var spriteGroup:FlxTypedSpriteGroup<FlxSprite> = cast m;
                spriteGroup.group.memberAdded.addOnce(onMemberAdded);
                if (checkMembers(cast spriteGroup.group) == true) {
                    found = true;
                    break;
                }
            }
        }
        return found;
    }
    
    private override function get_width():Float {
        return FlxG.width / Toolkit.scaleX;
    }
    
    private override function get_height() {
        return FlxG.height / Toolkit.scaleY;
    }
    
    private override function get_actualWidth():Float {
        return FlxG.width;
    }
    
    private override function get_actualHeight():Float {
        return FlxG.height;
    }
    
    private override function get_dpi():Float {
        return System.getDisplay(0).dpi;
    }
    
    private override function get_title():String {
        return Lib.current.stage.window.title;
    }
    
    private override function set_title(s:String):String {
        Lib.current.stage.window.title = s;
        return s;
    }
    
    private var _cursor:String = null;
    public function setCursor(cursor:String, offsetX:Null<Int> = null, offsetY:Null<Int> = null) {
        #if haxeui_flixel_no_custom_cursors
        return;
        #end

        if (!CursorHelper.useCustomCursors) {
            return;
        }

        if (_cursor == cursor) {
            return;
        }
        _cursor = cursor;
        if (CursorHelper.hasCursor(_cursor)) {
            var cursorInfo = CursorHelper.registeredCursors.get(_cursor);
            FlxG.mouse.load(new FlxSprite().loadGraphic(cursorInfo.graphic).pixels, cursorInfo.scale, cursorInfo.offsetX, cursorInfo.offsetY);
        } else if (openfl.Assets.exists(_cursor)) {
            FlxG.mouse.load(new FlxSprite().loadGraphic(_cursor).pixels, 1, offsetX, offsetY);
        } else {
            FlxG.mouse.load(null);
        }
    }

    public override function addComponent(component:Component):Component {
        if (rootComponents.length > 0) {
            var cameras = StateHelper.findCameras(rootComponents[0]);
            if (cameras != null) {
                component.cameras = cameras;
            }
        }
        
        if (StateHelper.currentState.exists == true) {
            StateHelper.currentState.add(component);
            if (rootComponents.indexOf(component) == -1) {
                rootComponents.push(component);
            }
            component.recursiveReady();
            onContainerResize();
            component.applyAddInternal();
        }
        return component;
    }
    
    public override function removeComponent(component:Component, dispose:Bool = true):Component {
        if (rootComponents.indexOf(component) == -1) {
            return component;
        }
        rootComponents.remove(component);
        if (rootComponents.indexOf(component) != -1) {
            throw "component wasnt actually removed from array, or there is a duplicate in the array";
        }
        if (dispose) {
            component.destroyInternal();
            component.destroy();
            component.destroyComponent();
        } else {
            component.applyRemoveInternal();
        }
        if (StateHelper.currentState.exists == true) {
            StateHelper.currentState.remove(component, true);
        }
        onContainerResize();
        return component;
    }
    
    private var _resizeHandlerAdded:Bool = false;
    private function addResizeHandler() {
        if (_resizeHandlerAdded == true) {
            return;
        }
        _resizeHandlerAdded = true;
        FlxG.signals.gameResized.add(onGameResized);
    }
    
    private function onGameResized(width:Int, height:Int) {
        onContainerResize();
    }
    
    private function onContainerResize() {
        for (c in rootComponents) {
            if (c.percentWidth > 0) {
                c.width = (this.width * c.percentWidth) / 100;
            }
            if (c.percentHeight > 0) {
                c.height = (this.height * c.percentHeight) / 100;
            }
        }
    }
    
    private override function handleSetComponentIndex(child:Component, index:Int) {
        var offset = 0;
        StateHelper.currentState.forEach((item) -> {
            offset++;
        });
        
        StateHelper.currentState.remove(child);
        StateHelper.currentState.insert(index + offset, child);
    }
    
    private override function supportsEvent(type:String):Bool {
        if (type == MouseEvent.MOUSE_MOVE
            || type == MouseEvent.MOUSE_DOWN
            || type == MouseEvent.MOUSE_UP
            || type == MouseEvent.RIGHT_MOUSE_DOWN
            || type == MouseEvent.RIGHT_MOUSE_UP
            || type == UIEvent.RESIZE
            || type == KeyboardEvent.KEY_DOWN
            || type == KeyboardEvent.KEY_UP
            || type == KeyboardEvent.KEY_PRESS) {
                return true;
            }
        return false;
    }
    
    private var _mouseDownButton:Int = 0;
    private override function mapEvent(type:String, listener:UIEvent->Void) {
        switch (type) {
            case MouseEvent.MOUSE_MOVE:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    MouseHelper.notify(MouseEvent.MOUSE_MOVE, __onMouseMove, 10);
                }
                
            case MouseEvent.MOUSE_DOWN | MouseEvent.RIGHT_MOUSE_DOWN:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    MouseHelper.notify(MouseEvent.MOUSE_DOWN, __onMouseDown, 10);
                }
                
            case MouseEvent.MOUSE_UP | MouseEvent.RIGHT_MOUSE_UP:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    MouseHelper.notify(MouseEvent.MOUSE_UP, __onMouseUp, 10);
                }
                
            case KeyboardEvent.KEY_DOWN:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, __onKeyEvent);
                }
                
            case KeyboardEvent.KEY_UP:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, __onKeyEvent);
                }
        }
    }
    
    private function __onMouseMove(event:MouseEvent) {
        var fn = _mapping.get(MouseEvent.MOUSE_MOVE);
        if (fn != null) {
            var mouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);
            mouseEvent.screenX = event.screenX / Toolkit.scaleX;
            mouseEvent.screenY = event.screenY / Toolkit.scaleY;
            mouseEvent.buttonDown = event.data;
            #if mobile
            mouseEvent.touchEvent = true;
            #end
            fn(mouseEvent);
            event.canceled = mouseEvent.canceled;
        }
    }
    
    private function __onMouseDown(event:MouseEvent) {
        var state = FlxG.state;
        if (state.subState != null) {
            state = state.subState;
        }
        /*
        var contains = containsUnsolicitedMemberAt(event.screenX, event.screenY, state);
        if (contains) { // lets attempt not in intercept unsolicated member events
            return;
        }
        */

        var fn = _mapping.get(MouseEvent.MOUSE_DOWN);
        if (fn != null) {
            var button:Int = event.data;
            var type = button == 0 ? MouseEvent.MOUSE_DOWN: MouseEvent.RIGHT_MOUSE_DOWN;
            var mouseEvent = new MouseEvent(type);
            mouseEvent.screenX = event.screenX / Toolkit.scaleX;
            mouseEvent.screenY = event.screenY / Toolkit.scaleY;
            mouseEvent.buttonDown = event.data;
            #if mobile
            mouseEvent.touchEvent = true;
            #end
            fn(mouseEvent);
            event.canceled = mouseEvent.canceled;
        }
    }
    
    private function __onMouseUp(event:MouseEvent) {
        var fn = _mapping.get(MouseEvent.MOUSE_UP);
        if (fn != null) {
            var button:Int = event.data;
            var type = button == 0 ? MouseEvent.MOUSE_UP: MouseEvent.RIGHT_MOUSE_UP;
            var mouseEvent = new MouseEvent(type);
            mouseEvent.screenX = event.screenX / Toolkit.scaleX;
            mouseEvent.screenY = event.screenY / Toolkit.scaleY;
            mouseEvent.buttonDown = event.data;
            #if mobile
            mouseEvent.touchEvent = true;
            #end
            fn(mouseEvent);
            event.canceled = mouseEvent.canceled;
        }
    }
    
    private function __onKeyEvent(event:openfl.events.KeyboardEvent) {
        var type:String = null;
        if (event.type == openfl.events.KeyboardEvent.KEY_DOWN) {
            type = KeyboardEvent.KEY_DOWN;
        } else if (event.type == openfl.events.KeyboardEvent.KEY_UP) {
            type = KeyboardEvent.KEY_UP;
        }

        if (type != null) {
            var fn = _mapping.get(type);
            if (fn != null) {
                var keyboardEvent = new KeyboardEvent(type);
                keyboardEvent.keyCode = event.keyCode;
                keyboardEvent.ctrlKey = event.ctrlKey;
                keyboardEvent.shiftKey = event.shiftKey;
                fn(keyboardEvent);
            }
        }
    }

    private function containsUnsolicitedMemberAt(x:Float, y:Float, state:FlxTypedGroup<FlxBasic>):Bool {
        if (state == null) {
            return false;
        }

        for (m in state.members) {
            if ((m is Component)) {
                var c:Component = cast m;
                if (c.hidden) {
                    continue;
                }
                if (!c.hitTest(x, y, true)) {
                    continue;
                }
                if (c._unsolicitedMembers != null && c._unsolicitedMembers.length > 0) {
                    for (um in c._unsolicitedMembers) {
                        var umx = um.sprite.x;
                        var umy = um.sprite.y;
                        var umw = um.sprite.width;
                        var umh = um.sprite.height;
                        if (x >= umx && y >= umy && x <= umx + umw && y <= umy + umh) {
                            return true;
                        }
                    }
                }
                var spriteGroup:FlxTypedSpriteGroup<FlxSprite> = cast m;
                if (containsUnsolicitedMemberAt(x, y, cast spriteGroup.group) == true) {
                    return true;
                }
            } else if ((m is FlxTypedSpriteGroup)) {
                var spriteGroup:FlxTypedSpriteGroup<FlxSprite> = cast m;
                if (!spriteGroup.visible) {
                    continue;
                }
                if (containsUnsolicitedMemberAt(x, y, cast spriteGroup.group) == true) {
                    return true;
                }
            } else if ((m is FlxSprite)) {
                var sprite:FlxSprite = cast m;
                var umx = sprite.x;
                var umy = sprite.y;
                var umw = sprite.width;
                var umh = sprite.height;
                if (x >= umx && y >= umy && x <= umx + umw && y <= umy + umh) {
                    return true;
                }
            }
        }

        return false;
    }
}