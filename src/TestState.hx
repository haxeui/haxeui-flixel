package;

import flixel.FlxObject;
import flixel.FlxSprite;
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
		
		// test(fsg);
	}
	
	function test(sprite:FlxSprite):Void {
		
		trace(sprite.x, sprite.y, sprite.frameWidth, sprite.frameHeight, sprite.offset);
		
		if (Std.is(sprite, FlxSpriteGroup)) {
			var fsg:FlxSpriteGroup = cast sprite;
			for (member in fsg.members) test(member);
		}
	}
}