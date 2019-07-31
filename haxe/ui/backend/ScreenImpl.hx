package haxe.ui.backend;

import flash.events.MouseEvent;
import flixel.FlxG;
import flixel.group.FlxGroup;
import haxe.ui.backend.flixel.FlxUIHelper;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import lime.system.System;
import openfl.Lib;

class ScreenImpl extends ScreenBase {
	
	public function new() {
		
	}
	
	private override function set_options(tko:ToolkitOptions):ToolkitOptions {
		
		if (options != null && options.container != null) {
			var fg:FlxGroup = options.container;
			if (fg.exists) fg.memberAdded.remove(FlxUIHelper.readyUI);
			else options.container = null; // clean up references to destroyed containers
		}
		
		super.options = tko;
		
		if (options != null) {
			
			if (options.container == null) options.container = FlxG.state;
			
			var fg:FlxGroup = options.container;
			fg.memberAdded.add(FlxUIHelper.readyUI);
		}
		
		return tko;
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
	
	public override function addComponent(component:Component) {
		container.add(component);
		component.ready(); // the component will already be ready from the add signal, but in case the user is only using Screen...
        _topLevelComponents.push(component);
        onContainerResize();
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
	
	public override function removeComponent(component:Component) {
		container.remove(component, true);
	}
	
	override function handleSetComponentIndex(child:Component, index:Int) {
		container.insert(index, child);
	}
	
	var container(get, null):FlxGroup;
	function get_container():FlxGroup {
		
		if (options != null && options.container != null) {
			return options.container;
		}
		
		return null;
	}
	
	var __eventMap:Map<String, flash.events.MouseEvent->Void> = new Map<String, flash.events.MouseEvent->Void>();
	override function mapEvent(type:String, listener:UIEvent->Void) {
		
		// utilizing the stage to capture "global" mouse events
		
		if (__eventMap.exists(type)) return;
		
		var cb = __onMouseEvent.bind(type, listener);
		__eventMap.set(type, cb);
		
		switch (type) {
			case haxe.ui.events.MouseEvent.MOUSE_OVER:
				FlxG.stage.addEventListener(flash.events.MouseEvent.MOUSE_OVER, cb);
			case haxe.ui.events.MouseEvent.MOUSE_OUT:
				FlxG.stage.addEventListener(flash.events.MouseEvent.MOUSE_OUT, cb);
			case haxe.ui.events.MouseEvent.MOUSE_DOWN:
				FlxG.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, cb);
			case haxe.ui.events.MouseEvent.MOUSE_UP:
				FlxG.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, cb);
			case haxe.ui.events.MouseEvent.CLICK:
				FlxG.stage.addEventListener(flash.events.MouseEvent.CLICK, cb);
			case haxe.ui.events.MouseEvent.MOUSE_MOVE:
				FlxG.stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, cb);
			case haxe.ui.events.MouseEvent.MOUSE_WHEEL:
				FlxG.stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, cb);
		}
	}
	
	override function unmapEvent(type:String, listener:UIEvent->Void) {
		
		if (!__eventMap.exists(type)) return;
		
		var cb = __eventMap.get(type);
		__eventMap.remove(type);
		
		switch (type) {
			case haxe.ui.events.MouseEvent.MOUSE_OVER:
				FlxG.stage.removeEventListener(flash.events.MouseEvent.MOUSE_OVER, cb);
			case haxe.ui.events.MouseEvent.MOUSE_OUT:
				FlxG.stage.removeEventListener(flash.events.MouseEvent.MOUSE_OUT, cb);
			case haxe.ui.events.MouseEvent.MOUSE_DOWN:
				FlxG.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, cb);
			case haxe.ui.events.MouseEvent.MOUSE_UP:
				FlxG.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, cb);
			case haxe.ui.events.MouseEvent.CLICK:
				FlxG.stage.removeEventListener(flash.events.MouseEvent.CLICK, cb);
			case haxe.ui.events.MouseEvent.MOUSE_MOVE:
				FlxG.stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, cb);
			case haxe.ui.events.MouseEvent.MOUSE_WHEEL:
				FlxG.stage.removeEventListener(flash.events.MouseEvent.MOUSE_WHEEL, cb);
		}
	}
	
	function __onMouseEvent(type:String, listener:UIEvent->Void, ome:flash.events.MouseEvent):Void {
		
		var me = new haxe.ui.events.MouseEvent(type);
		// store ome in here?
		me.screenX = FlxG.mouse.screenX;
		me.screenY = FlxG.mouse.screenY;
		me.buttonDown = FlxG.mouse.pressed;
		if (type == haxe.ui.events.MouseEvent.MOUSE_WHEEL) me.delta = FlxG.mouse.wheel;
		listener(me);
	}
	
	override function supportsEvent(type:String):Bool {
		// not key events...
		return true;
	}
}