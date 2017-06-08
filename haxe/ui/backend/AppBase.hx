package haxe.ui.backend;

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
	
	public function start() {
		
	}
}
