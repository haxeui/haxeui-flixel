package haxe.ui.backend;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;
import lime.system.System;
import openfl.Lib;

class ScreenBase {
	
	public function new() {
		
	}

	public var options:Dynamic;

	public var width(get, null):Float;
	public function get_width():Float {
		return container.width;
	}

	public var height(get, null):Float;
	public function get_height() {
		return container.height;
	}

	public var focus:Component;

	public var dpi(get, null):Float;
	public function get_dpi():Float {
		return System.getDisplay(0).dpi;
	}
	
	public function addComponent(component:Component) {
		container.add(component);
		component.ready();
	}
	
	public var title(get, set):String;
	inline function get_title():String { return Lib.current.stage.window.title; }
	inline function set_title(s:String):String {
		Lib.current.stage.window.title = s;
		return s;
    }

	public function removeComponent(component:Component) {
		container.remove(component, true);
	}

	function handleSetComponentIndex(child:Component, index:Int) {
		container.group.insert(index, child);
	}

	var container(get, null):FlxSpriteGroup;
	function get_container():FlxSpriteGroup {
		
		if (options != null && options.container != null) {
			return options.container;
		}
		
		throw "Please set a FlxSpriteGroup as the container when initializing the Toolkit: Toolkit.init( { container : fsg } );";
	}
	
	var __mouseRegistered:Bool = false;
	function mapEvent(type:String, listener:UIEvent->Void) {
		
		if (!__mouseRegistered) {
			FlxMouseEventManager.add(container, null, null, null, null, true, true, false);
			__mouseRegistered = true;
		}
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxMouseEventManager.setMouseOverCallback(container, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_OUT:
				FlxMouseEventManager.setMouseOutCallback(container, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_DOWN:
				FlxMouseEventManager.setMouseDownCallback(container, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_UP:
				FlxMouseEventManager.setMouseUpCallback(container, __onMouseEvent.bind(type, listener));
			case MouseEvent.CLICK:
				FlxMouseEventManager.setMouseClickCallback(container, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_MOVE:
				FlxMouseEventManager.setMouseMoveCallback(container, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_WHEEL:
				FlxMouseEventManager.setMouseWheelCallback(container, __onMouseEvent.bind(type, listener));
		}
	}
	
	function unmapEvent(type:String, listener:UIEvent->Void) {
		
		if (!__mouseRegistered) return;
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxMouseEventManager.setMouseOverCallback(container, null);
			case MouseEvent.MOUSE_OUT:
				FlxMouseEventManager.setMouseOutCallback(container, null);
			case MouseEvent.MOUSE_DOWN:
				FlxMouseEventManager.setMouseDownCallback(container, null);
			case MouseEvent.MOUSE_UP:
				FlxMouseEventManager.setMouseUpCallback(container, null);
			case MouseEvent.CLICK:
				FlxMouseEventManager.setMouseClickCallback(container, null);
			case MouseEvent.MOUSE_MOVE:
				FlxMouseEventManager.setMouseMoveCallback(container, null);
			case MouseEvent.MOUSE_WHEEL:
				FlxMouseEventManager.setMouseWheelCallback(container, null);
		}
	}
	
	function __onMouseEvent(type:String, listener:UIEvent->Void, target:FlxObject):Void {
		
		var me = new MouseEvent(type);
		// me.target = cast target;
		me.screenX = FlxG.mouse.screenX;
		me.screenY = FlxG.mouse.screenY;
		me.buttonDown = FlxG.mouse.pressed;
		if (type == MouseEvent.MOUSE_WHEEL) me.delta = FlxG.mouse.wheel;
		listener(me);
	}
	
	function supportsEvent(type:String):Bool {
		// not key events...
		return container != null;
	}

	public function messageDialog(message:String, title:String = null, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
		return null;
	}

	public function showDialog(content:Component, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
		return null;
	}

	public function hideDialog(dialog:Dialog):Bool {
		return false;
	}
}