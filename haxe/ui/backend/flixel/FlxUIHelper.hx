package haxe.ui.backend.flixel;

import flixel.FlxSprite;
import haxe.ui.core.Component;

/**
 * ...
 * @author MSGhero
 */
class FlxUIHelper {
	
	public static function readyUI(child:FlxSprite):Void {
		
		if (Std.is(child, Component)) {
			cast(child, Component).ready();
		}
	}
}