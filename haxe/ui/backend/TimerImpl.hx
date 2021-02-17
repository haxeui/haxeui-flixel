package haxe.ui.backend;

import flixel.util.FlxTimer;

class TimerImpl {
	
	private var _timer:FlxTimer;

	public function new(delay:Int, callback:Void->Void) {
		_timer = new FlxTimer();
        var d = delay / 1000;
        var loops = 1;
        if (d > 0) {
            loops = 0;
        }
		_timer.start(d, function(_) {
			callback();
		}, loops);
	}

	public function stop() {
		_timer.cancel();
	}
}