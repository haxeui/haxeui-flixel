package haxe.ui.backend;

import haxe.ui.core.UIEvent;

class EventBase {
	
    public function new() { }
    
    public function cancel() { }
    
    private function postClone(event:UIEvent) { }
}
