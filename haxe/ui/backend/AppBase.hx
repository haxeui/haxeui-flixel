package haxe.ui.backend;

import flixel.FlxG;
import flixel.FlxGame;
import haxe.ui.Preloader.PreloadItem;
import haxe.ui.backend.flixel.FlxHaxeUIState;
import openfl.Lib;

class AppBase {
	
	public function new() {
		
	}
	
	function build() {
		Lib.current.stage.addChild(new FlxGame(0, 0, FlxHaxeUIState, 1, 60, 60, true));
	}
	
	function init(onReady:Void->Void, onEnd:Void->Void = null) {
		onReady();
	}
	
	function getToolkitInit():Dynamic {
		return { };
	}
	
	function buildPreloadList():Array<PreloadItem> {
		return [];
	}
	
	public function start() {
		
	}
}
