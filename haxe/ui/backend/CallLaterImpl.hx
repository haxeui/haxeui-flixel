package haxe.ui.backend;

import flixel.FlxG;

// we'll flip between two list references between updates meaning there is breathing space
// between calls rather that just filling a list and blocking
class CallLaterImpl {

    private static var added:Bool = false;
    private static var current:Array<Void->Void>;
    private static var list1:Array<Void->Void> = [];
    private static var list2:Array<Void->Void> = [];
    public function new(fn:Void->Void) {
        if (!added) {
            added = true;
            current = list1;
            FlxG.signals.preUpdate.add(onUpdate);
        }
        current.insert(0, fn);
    }

    private static function onUpdate() {
        var ref = current;
        if (current == list1) {
            current = list2;
        } else {
            current = list1;
        }
        while (ref.length > 0) {
            ref.pop()();
        }
    }
}
