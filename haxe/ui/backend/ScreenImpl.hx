package haxe.ui.backend;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import haxe.ui.backend.flixel.MouseHelper;
import haxe.ui.backend.flixel.StateHelper;
import haxe.ui.core.Component;
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
        onPostStateSwitch();
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
        } else if ((m is FlxTypedGroup)) {
            var group:FlxTypedGroup<FlxBasic> = cast m;
            checkMembers(group);
        }
    }
    
    private function onMemberRemoved(m:FlxBasic) {
        if ((m is Component) && rootComponents.indexOf(cast(m, Component)) != -1) {
            removeComponent(cast m);
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
		return FlxG.width;
	}
	
	private override function get_height() {
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
    
    public override function addComponent(component:Component):Component {
        if (rootComponents.length > 0) {
            var cameras = StateHelper.findCameras(rootComponents[0]);
            if (cameras != null) {
                component.cameras = cameras;
            }
        }
        
        if (StateHelper.currentState.exists == true) {
            StateHelper.currentState.add(component);
            rootComponents.push(component);
            component.recursiveReady();
            onContainerResize();
        }
        return component;
    }
    
	public override function removeComponent(component:Component):Component {
        if (StateHelper.currentState.exists == true) {
            StateHelper.currentState.remove(component, true);
        }
        rootComponents.remove(component);
        onContainerResize();
		return component;
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
        StateHelper.currentState.remove(child);
        StateHelper.currentState.insert(index, child);
    }
    
    private override function supportsEvent(type:String):Bool {
        if (type == MouseEvent.MOUSE_MOVE
            || type == MouseEvent.MOUSE_DOWN
            || type == MouseEvent.MOUSE_UP) {
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
                    MouseHelper.notify(MouseEvent.MOUSE_MOVE, __onMouseMove);
                }
                
            case MouseEvent.MOUSE_DOWN:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    MouseHelper.notify(MouseEvent.MOUSE_DOWN, __onMouseDown);
                }
                
            case MouseEvent.MOUSE_UP:
                if (_mapping.exists(type) == false) {
                    _mapping.set(type, listener);
                    MouseHelper.notify(MouseEvent.MOUSE_UP, __onMouseUp);
                }
        }
    }
    
    private function __onMouseMove(event:MouseEvent) {
        var fn = _mapping.get(MouseEvent.MOUSE_MOVE);
        if (fn != null) {
            var mouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);
            mouseEvent.screenX = event.screenX;
            mouseEvent.screenY = event.screenY;
            mouseEvent.buttonDown = event.data;
            fn(mouseEvent);
        }
    }
    
    private function __onMouseDown(event:MouseEvent) {
        var fn = _mapping.get(MouseEvent.MOUSE_DOWN);
        if (fn != null) {
            var mouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN);
            mouseEvent.screenX = event.screenX;
            mouseEvent.screenY = event.screenY;
            mouseEvent.buttonDown = event.data;
            fn(mouseEvent);
        }
    }
    
    private function __onMouseUp(event:MouseEvent) {
        var fn = _mapping.get(MouseEvent.MOUSE_UP);
        if (fn != null) {
            var mouseEvent = new MouseEvent(MouseEvent.MOUSE_UP);
            mouseEvent.screenX = event.screenX;
            mouseEvent.screenY = event.screenY;
            mouseEvent.buttonDown = event.data;
            fn(mouseEvent);
        }
    }
}