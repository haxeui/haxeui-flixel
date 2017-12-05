package haxe.ui.backend;

import haxe.ui.Preloader.PreloadItem;

class AppBase {
	
	public function new() {
		
	}
	
	function build() {
		
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
