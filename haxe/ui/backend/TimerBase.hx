package haxe.ui.backend;

import flixel.util.FlxTimer;

class TimerBase {
	
	private var _timer:FlxTimer;

	public function new(delay:Int, callback:Void->Void) {
		
		_timer = new FlxTimer();
		_timer.start(delay / 1000, function(_) {
			callback();
		});
	}

	public function stop() {
		_timer.cancel();
	}
}