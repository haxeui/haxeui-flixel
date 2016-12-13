package haxe.ui.backend;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import haxe.ui.core.Component;
import haxe.ui.core.IComponentBase;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.core.UIEvent;
import haxe.ui.styles.Style;
import haxe.ui.util.Rectangle;

class ComponentBase extends FlxSpriteGroup implements IComponentBase {

	var surface:FlxSprite;
	
    public function new() {
        super();
		surface = new FlxSprite();
		add(surface);
    }
    
    private function applyStyle(style:Style) {
		
		if (style.backgroundColor != null) {
			surface.makeGraphic(Std.int(width), Std.int(height), Std.int((style.backgroundOpacity == null ? 1 : style.backgroundOpacity) * 0xFF) << 24 | style.backgroundColor, true);
		}
    }

    public function getTextDisplay():TextDisplay {
        return null;
    }

    public function hasTextDisplay():Bool {
        return false;
    }

    public function getTextInput():TextInput {
        return null;
    }

    public function hasTextInput():Bool {
        return false;
    }

    public function getImageDisplay():ImageDisplay {
        return null;
    }

    public function hasImageDisplay():Bool {
        return false;
    }

    public function removeImageDisplay():Void {

    }

    private function handleAddComponent(child:Component):Component {
        add(child);
        return child;
    }

    private function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
        if (members.indexOf(child) > -1) {
            remove(child, true);
        }
        return child;
    }

    private function handleSetComponentIndex(child:Component, index:Int) {
        group.insert(index, child);
    }

    private function handleVisibility(show:Bool):Void {
        this.visible = show;
    }

    private function handleCreate(native:Bool):Void {

    }

    private function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		
    }

    private function handleClipRect(value:Rectangle):Void {

    }

    private function handlePosition(left:Null<Float>, top:Null<Float>, style:Style):Void {

    }

    private function handlePreReposition() {

    }

    private function handlePostReposition() {

    }

    private function handleReady() {

    }

    private function mapEvent(type:String, listener:UIEvent->Void) {

    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {

    }
	
	private var __ready:Bool = false;
	override public function draw():Void {
		
		if (!__ready) {
			__ready = true;
			cast(this, Component).ready();
		}
		
		super.draw();
	}
}