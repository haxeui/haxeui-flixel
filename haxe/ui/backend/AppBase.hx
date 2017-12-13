package haxe.ui.backend;

import flixel.FlxG;
import haxe.ui.Preloader.PreloadItem;
import haxe.ui.backend.flixel.FlxUIHelper;

class AppBase {
	
	public function new() {
		
	}
	
	function build() {
		
	}
	
	function init(onReady:Void->Void, onEnd:Void->Void = null) {
		onReady();
	}
	
	function getToolkitInit():Dynamic {
		FlxG.state.memberAdded.add(FlxUIHelper.readyUI);
		return { container : FlxG.state };
	}
	
	function buildPreloadList():Array<PreloadItem> {
		return [];
	}
	
	public function start() {
		
	}
}
