package;

import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import haxe.ui.Toolkit;
import haxe.ui.core.MouseEvent;
import haxe.ui.macros.ComponentMacros;


class TestState extends FlxState {
	
	override public function create():Void {
		super.create();
		
		var fsg = new FlxSpriteGroup();
		add(fsg);
		
		Toolkit.init( { container : fsg } );
		
		var comp = ComponentMacros.buildComponent("assets/test.xml");
		fsg.add(comp);
		
		comp.registerEvent(MouseEvent.MOUSE_UP, testMUp);
		comp.registerEvent(MouseEvent.MOUSE_DOWN, testMDown);
		comp.registerEvent(MouseEvent.MOUSE_OVER, testMOver);
		comp.registerEvent(MouseEvent.MOUSE_OUT, testMOut);
	}
	
	function testMUp(me:MouseEvent):Void {
		trace("up");
	}
	
	function testMDown(me:MouseEvent):Void {
		trace("down");
	}
	
	function testMOver(me:MouseEvent):Void {
		trace("over");
	}
	
	function testMOut(me:MouseEvent):Void {
		trace("out");
	}
}