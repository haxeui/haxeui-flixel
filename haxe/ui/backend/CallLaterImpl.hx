package haxe.ui.backend;
import flixel.FlxG;

class CallLaterImpl extends TimerImpl {
	public function new(callback:Void->Void) {
		super(0, callback);
	}
}