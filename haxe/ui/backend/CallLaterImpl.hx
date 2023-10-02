package haxe.ui.backend;

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