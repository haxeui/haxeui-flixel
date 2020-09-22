package haxe.ui.backend.flixel;
import flixel.input.IFlxInputManager;

class InputManager implements IFlxInputManager {
    public var onResetCb:Void->Void;
    
    public function new() {
    }
    
	public function reset():Void {
        if (onResetCb != null) {
            onResetCb();
        }
    }
	private function update():Void {
        
    }
	private function onFocus():Void {
        
    }
	private function onFocusLost():Void {
        
    }
	public function destroy():Void {
        
    }
}