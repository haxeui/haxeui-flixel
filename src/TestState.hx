package;

import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import haxe.ui.Toolkit;
import haxe.ui.macros.ComponentMacros;


class TestState extends FlxState {
	
	override public function create():Void {
		super.create();
		
		var fsg = new FlxSpriteGroup();
		add(fsg);
		
		Toolkit.init( { container : fsg } );
		
		var comp = ComponentMacros.buildComponent("assets/test.xml");
		fsg.add(comp);
	}
}