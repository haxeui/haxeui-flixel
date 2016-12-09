package;

import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import haxe.ui.Toolkit;


class TestState extends FlxState {
	
	override public function create():Void {
		super.create();
		
		var fsg = new FlxSpriteGroup();
		add(fsg);
		
		Toolkit.init( { container : fsg } );
	}
}