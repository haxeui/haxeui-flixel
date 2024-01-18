package haxe.ui.backend;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import haxe.ui.backend.flixel.KeyboardHelper;
import haxe.ui.backend.flixel.MouseHelper;
import haxe.ui.backend.flixel.StateHelper;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.tooltips.ToolTipManager;
import lime.system.System;
import openfl.Lib;

@:access(haxe.ui.backend.ComponentImpl)
class ScreenImpl extends ScreenBase {
    private var _mapping:Map<String, UIEvent->Void>;

    public function new() {
        _mapping = new Map<String, UIEvent->Void>();

        FlxG.signals.postGameStart.add(onPostGameStart);
        FlxG.signals.preStateSwitch.add(onPreStateSwitch);
        FlxG.signals.postStateSwitch.add(onPostStateSwitch);
        FlxG.signals.preStateCreate.add(onPreStateCreate);
        onPostStateSwitch();

        addResizeHandler();
    }

    private function onPreStateCreate(state:flixel.FlxState) {
        if (!state.memberAdded.has(onMemberAdded)) {
            state.memberAdded.add(onMemberAdded);
        }
        checkMembers(state);
        if (!state.memberRemoved.has(onMemberRemoved)) {
            state.memberRemoved.add(onMemberRemoved);
        }
    }

    private function onPostGameStart() {
        onPostStateSwitch();
    }

    private function onPreStateSwitch() {
        if (FlxG.game == null) {
            return;
        }
        ToolTipManager.instance.reset();
        if (rootComponents != null) {
            while (rootComponents.length > 0) {
                var root = rootComponents[rootComponents.length - 1];
                removeComponent(root);
            }
        }
        rootComponents = [];
    }

    private function onPostStateSwitch() {
        if (FlxG.game == null) {
            return;
        }

        if (!FlxG.state.subStateOpened.has(onMemberAdded)) {
            FlxG.state.subStateOpened.add(onMemberAdded);
        }
        if (!FlxG.state.memberAdded.has(onMemberAdded)) {
            FlxG.state.memberAdded.add(onMemberAdded);
        }
        checkMembers(FlxG.state);

        if (!FlxG.state.memberRemoved.has(onMemberRemoved)) {
            FlxG.state.memberRemoved.add(onMemberRemoved);
        }
        if (!FlxG.state.subStateClosed.has(onMemberRemoved)) {
            FlxG.state.subStateClosed.add(onMemberRemoved);
        }
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
            c.state = StateHelper.currentState;
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
                c.state = StateHelper.currentState;
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
            FlxG.mouse.load(CursorHelper.mouseLoadFunction(cursorInfo.graphic), cursorInfo.scale, cursorInfo.offsetX, cursorInfo.offsetY);
        } else if (openfl.Assets.exists(_cursor)) {
            FlxG.mouse.load(CursorHelper.mouseLoadFunction(_cursor), 1, offsetX, offsetY);
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
            checkResetCursor();
        }
        return component;
    }

    public override function removeComponent(component:Component, dispose:Bool = true):Component {
        if (rootComponents.indexOf(component) == -1) {
            if (dispose) {
                component.disposeComponent();
            }
            return component;
        }
        rootComponents.remove(component);
        if (rootComponents.indexOf(component) != -1) {
            throw "component wasnt actually removed from array, or there is a duplicate in the array";
        }
        if (dispose) {
            component.disposeComponent();
        } else {
            component.applyRemoveInternal();
        }
        if (StateHelper.currentState.exists == true) {
            StateHelper.currentState.remove(component, true);
        }
        checkResetCursor();
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
                    KeyboardHelper.notify(KeyboardEvent.KEY_DOWN, __onKeyEvent, 10);
                }

            case KeyboardEvent.KEY_UP:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    KeyboardHelper.notify(KeyboardEvent.KEY_UP, __onKeyEvent, 10);
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

    private function __onKeyEvent(event:KeyboardEvent) {
        var fn = _mapping.get(event.type);
        if (fn != null) {
            var keyboardEvent = new KeyboardEvent(event.type);
            keyboardEvent.keyCode = event.keyCode;
            keyboardEvent.altKey = event.altKey;
            keyboardEvent.ctrlKey = event.ctrlKey;
            keyboardEvent.shiftKey = event.shiftKey;
            fn(keyboardEvent);
            event.canceled = keyboardEvent.canceled;
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

    private function checkResetCursor(x:Null<Float> = null, y:Null<Float> = null) {
        if (x == null) {
            x = MouseHelper.currentMouseX;
        }
        if (y == null) {
            y = MouseHelper.currentMouseY;
        }
        var components = Screen.instance.findComponentsUnderPoint(x, y);
        var desiredCursor = "default";
        var desiredCursorOffsetX:Null<Int> = null;
        var desiredCursorOffsetY:Null<Int> = null;
        for (c in components) {
            if (c.style == null) {
                c.validateNow();
            }
            if (c.style.cursor != null) {
                desiredCursor = c.style.cursor;
                desiredCursorOffsetX = c.style.cursorOffsetX;
                desiredCursorOffsetX = c.style.cursorOffsetY;
                break;
            }
        }

        setCursor(desiredCursor, desiredCursorOffsetX, desiredCursorOffsetY);
    }
}
