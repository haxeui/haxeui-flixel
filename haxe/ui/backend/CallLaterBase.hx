package haxe.ui.backend;

class CallLaterBase extends TimerBase {
	
	public function new(callback:Void->Void) {
		super(0, callback);
	}
}