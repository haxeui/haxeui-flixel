package haxe.ui.backend;

import flixel.group.FlxSpriteGroup;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.core.Component;
import haxe.ui.core.UIEvent;
import openfl.Lib;
import lime.system.System;

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

	var _topLevelComponents:Array<Component> = new Array<Component>();
	public function addComponent(component:Component) {
		_topLevelComponents.push(component);
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
		_topLevelComponents.remove(component);
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

	function mapEvent(type:String, listener:UIEvent->Void) {
		
	}
	
	function unmapEvent(type:String, listener:UIEvent->Void) {
		
	}
	
	function supportsEvent(type:String):Bool {
		return false;
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