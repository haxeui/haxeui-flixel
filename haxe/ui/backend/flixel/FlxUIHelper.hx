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
			
			var comp:Component = cast child;
			comp.ready(); // tells HaxeUI to finish up on its end
			comp.syncComponentValidation(); // force UI validation, giving Flixel (and you) immediate access to the laid out components
		}
	}
}