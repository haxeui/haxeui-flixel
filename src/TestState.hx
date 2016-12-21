package;

import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import haxe.ui.Toolkit;
import haxe.ui.assets.ImageInfo;
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
		
		Toolkit.assets.getImage("assets/test.png", test);
	}
	
	function test(ii:ImageInfo):Void {
		trace(ii.width, ii.height);
	}
}