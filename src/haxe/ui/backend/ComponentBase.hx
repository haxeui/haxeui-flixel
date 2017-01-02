package haxe.ui.backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import haxe.ui.core.Component;
import haxe.ui.core.IComponentBase;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.core.UIEvent;
import haxe.ui.styles.Style;
import haxe.ui.util.Rectangle;

class ComponentBase extends FlxSpriteGroup implements IComponentBase {

	var surface:FlxSprite; // drawing surface
	var image:ImageDisplay; // where images are displayed
    var tf:TextDisplay; // text
	
    public function new() {
		super();
		
		surface = new FlxSprite();
		add(surface);
    }
	
    private function applyStyle(style:Style) {
		
		if (surface.pixels == null) return; // nothing to draw onto yet
		
		if (style.backgroundColor != null) {
			var color = Std.int((style.backgroundOpacity == null ? 1 : style.backgroundOpacity) * 0xFF) << 24 | style.backgroundColor;
			var bmd = surface.pixels;
			bmd.fillRect(bmd.rect, color);
		}
    }

    public function getImageDisplay():ImageDisplay {
        
		if (image != null) return image;
		
		image = new ImageDisplay();
		image.parent = cast this;
		add(image);
		
		return image;
    }

    public function hasImageDisplay():Bool {
        return image != null;
    }

    public function removeImageDisplay():Void {
		if (image != null) remove(image, true);
    }

    public function getTextDisplay():TextDisplay {
		
        if (tf != null) return tf; 
        
        tf = new TextDisplay();
        tf.parent = cast this;
		add(tf);
		
        return tf;
    }

    public function hasTextDisplay():Bool {
        return tf != null;
    }

    public function getTextInput():TextInput {
        return null;
    }

    public function hasTextInput():Bool {
        return false;
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

    private function handleSetComponentIndex(child:Component, index:Int):Void {
        group.insert(index, child);
    }

    private function handleVisibility(show:Bool):Void {
        visible = show;
    }

    private function handleCreate(native:Bool):Void {

    }

    private function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		
		this.width = width;
		this.height = height;
		
		surface.makeGraphic(Std.int(width), Std.int(height), 0x0, true);
		
		applyStyle(style);
    }

    private function handleClipRect(value:Rectangle):Void {

    }

    private function handlePosition(left:Null<Float>, top:Null<Float>, style:Style):Void {
		x = left;
		y = top;
    }

    private function handlePreReposition() {

    }

    private function handlePostReposition() {

    }

    private function handleReady() {
		
    }
	
	private var __mouseRegistered:Bool = false;
    private function mapEvent(type:String, listener:UIEvent->Void) {
		
		if (!__mouseRegistered) {
			FlxMouseEventManager.add(this);
			__mouseRegistered = true;
		}
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxMouseEventManager.setMouseOverCallback(this, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_OUT:
				FlxMouseEventManager.setMouseOutCallback(this, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_DOWN:
				FlxMouseEventManager.setMouseDownCallback(this, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_UP:
				FlxMouseEventManager.setMouseUpCallback(this, __onMouseEvent.bind(type, listener));
			// case MouseEvent.CLICK:
				// 
		}
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {
		
		if (!__mouseRegistered) {
			return;
		}
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxMouseEventManager.setMouseOverCallback(this, null);
			case MouseEvent.MOUSE_OUT:
				FlxMouseEventManager.setMouseOutCallback(this, null);
			case MouseEvent.MOUSE_DOWN:
				FlxMouseEventManager.setMouseDownCallback(this, null);
			case MouseEvent.MOUSE_UP:
				FlxMouseEventManager.setMouseUpCallback(this, null);
			// case MouseEvent.CLICK:
				// 
		}
    }
	
	private function __onMouseEvent(type:String, listener:UIEvent->Void, target:ComponentBase):Void {
		
		var me = new MouseEvent(type);
		me.target = cast target;
		me.screenX = FlxG.mouse.x;
		me.screenY = FlxG.mouse.y;
		me.buttonDown = FlxG.mouse.pressed;
		// me.delta = ?
		listener(me);
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