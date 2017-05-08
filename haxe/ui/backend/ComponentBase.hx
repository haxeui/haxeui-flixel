package haxe.ui.backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxRect;
import haxe.ui.backend.flixel.FlxStyleHelper;
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
	
	var asComponent:Component = cast this;
	
    public function new() {
		super();
		
		surface = new FlxSprite();
		add(surface);
    }
	
    function applyStyle(style:Style) {
		FlxStyleHelper.applyStyle(surface, style);
    }

    public function getImageDisplay():ImageDisplay {
		
		if (image != null) return image;
		
		image = new ImageDisplay();
		image.parent = asComponent;
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
        tf.parent = asComponent;
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

    function handleAddComponent(child:Component):Component {
        add(child);
        return child;
    }

    function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
		
        if (members.indexOf(child) > -1) {
            remove(child, true);
        }
		
        return child;
    }

    function handleSetComponentIndex(child:Component, index:Int):Void {
        insert(index, child);
    }

    function handleVisibility(show:Bool):Void {
        visible = show;
    }

    function handleCreate(native:Bool):Void {
		
    }

    function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		
		surface.makeGraphic(Std.int(width), Std.int(height), 0x0, true);
		
		if (clipRect != null) surface.clipRect = clipRect;
		
		applyStyle(style);
    }

    function handleClipRect(value:Rectangle):Void {
		if (value == null) clipRect = null;
		else clipRect = FlxRect.get(value.left, value.top, value.width, value.height);
    }

    function handlePosition(left:Null<Float>, top:Null<Float>, style:Style):Void {
		asComponent.left = left;
		asComponent.top = top;
    }

    function handlePreReposition() {
		
    }

    function handlePostReposition() {
		
    }

    function handleReady() {
		
    }
	
	var __mouseRegistered:Bool = false;
    function mapEvent(type:String, listener:UIEvent->Void) {
		
		if (!__mouseRegistered) {
			FlxMouseEventManager.add(this, null, null, null, null, true);
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

    function unmapEvent(type:String, listener:UIEvent->Void) {
		
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
	
	function __onMouseEvent(type:String, listener:UIEvent->Void, target:ComponentBase):Void {
		
		var me = new MouseEvent(type);
		me.target = cast target;
		me.screenX = FlxG.mouse.x;
		me.screenY = FlxG.mouse.y;
		me.buttonDown = FlxG.mouse.pressed;
		// me.delta = ?
		listener(me);
	}
	
	var __ready:Bool = false;
	override public function draw():Void {
		
		if (!__ready) {
			__ready = true;
			asComponent.ready();
		}
		
		if (dirty) {
			x = asComponent.screenLeft;
			y = asComponent.screenTop;
		}
		
		super.draw();
	}
}