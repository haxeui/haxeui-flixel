package haxe.ui.backend;

class CallLaterImpl {
    public function new(fn:Void->Void) {
        haxe.ui.util.Timer.delay(fn, 0);
    }
}