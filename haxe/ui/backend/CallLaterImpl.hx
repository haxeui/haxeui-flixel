package haxe.ui.backend;

class CallLaterImpl {
    public function new(fn:Void->Void) {
        haxe.ui.util.Timer.delay(fn, 0);
    }
}

/* this version seems to hold the main loop up - unsure why, but animations simply dont work - even though the props seem to be get set correctly
import flixel.FlxG;

class CallLaterImpl {
    private static var added:Bool = false;
    private static var fns:Array<Void->Void> = [];
    public function new(fn:Void->Void) {
        if (!added) {
            FlxG.signals.preUpdate.add(onUpdate);
            added = true;
        }
        fns.insert(0, fn);
    }

    private static function onUpdate() {
        while (fns.length > 0) {
            fns.pop()();
        }
    }
}
*/