package haxe.ui.backend;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.ui.backend.flixel.MouseHelper;
import haxe.ui.backend.flixel.StateHelper;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import lime.system.System;
import openfl.Lib;

class ScreenImpl extends ScreenBase {
    private var _mapping:Map<String, UIEvent->Void>;
    
    public function new() {
        _mapping = new Map<String, UIEvent->Void>();
        
        FlxG.signals.postStateSwitch.add(onPostStateSwitch);
    }
    
    private function onPostStateSwitch() {
        _topLevelComponents = [];
        checkMembers(FlxG.state);
    }
    
    private function checkMembers(state:FlxTypedGroup<FlxBasic>) {
        var found = false; // we only want top level components
        for (m in state.members) {
            if (Std.is(m, Component)) {
                var c = cast(m, Component);
                if (c.percentWidth > 0) {
                    c.width = (this.width * c.percentWidth) / 100;
                }
                if (c.percentHeight > 0) {
                    c.height = (this.height * c.percentHeight) / 100;
                }
                _topLevelComponents.push(c);
                found = true;
            } else if (Std.is(m, FlxTypedGroup)) {
                var group:FlxTypedGroup<FlxBasic> = cast m;
                if (checkMembers(group) == true) {
                    found = true;
                    break;
                }
                trace("its a group");
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
        if (_topLevelComponents.length > 0) {
            var cameras = StateHelper.findCameras(_topLevelComponents[0]);
            if (cameras != null) {
                component.cameras = cameras;
            }
        }
        
        StateHelper.currentState.add(component);
        _topLevelComponents.push(component);
        onContainerResize();
        return component;
    }
    
	public override function removeComponent(component:Component):Component {
		StateHelper.currentState.remove(component, true);
        _topLevelComponents.remove(component);
        onContainerResize();
		return component;
	}
    
    private function onContainerResize() {
        for (c in _topLevelComponents) {
            if (c.percentWidth > 0) {
                c.width = (this.width * c.percentWidth) / 100;
            }
            if (c.percentHeight > 0) {
                c.height = (this.height * c.percentHeight) / 100;
            }
        }
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