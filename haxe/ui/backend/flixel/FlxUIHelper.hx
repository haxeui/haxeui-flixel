package haxe.ui.backend.flixel;

import flixel.FlxBasic;
import haxe.ui.core.Component;

/**
 * ...
 * @author MSGhero
 */
class FlxUIHelper {
	
	public static function readyUI(child:FlxBasic):Void {
		
		// lets the child component know it's just been added to a FlxGroup
		if (Std.is(child, Component)) {
			cast(child, Component).ready(); // tells HaxeUI to finish up on its end
		}
	}
}