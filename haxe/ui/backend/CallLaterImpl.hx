package haxe.ui.backend;

class CallLaterImpl extends TimerImpl {
	
	public function new(callback:Void->Void) {
		super(0, callback);
	}
}