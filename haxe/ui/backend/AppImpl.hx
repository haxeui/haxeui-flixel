package haxe.ui.backend;

import flixel.FlxGame;
import haxe.ui.backend.flixel.FlxHaxeUIAppState;
import openfl.Lib;

class AppImpl extends AppBase {
	public function new() {
	}
	
	private override function build() {
		Lib.current.stage.addChild(new FlxGame(0, 0, FlxHaxeUIAppState, 1, 60, 60, true));
	}
}
