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
		
		scrollFactor.set(0, 0); // ui doesn't scroll by default
		
		surface = new FlxSprite();
		surface.makeGraphic(1, 1, 0x0, true);
		add(surface);
	}
	
	override public function destroy():Void {
		super.destroy();
		
		if (__mouseRegistered) {
			FlxMouseEventManager.remove(this);
			__mouseRegistered = false;
		}
		
		if (surface != null) surface.destroy();
		surface = null;
		if (image != null) image.destroy();
		image = null;
		if (tf != null) tf.tf.destroy();
		tf = null;
		
		asComponent = null;
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
		
		if (image != null) {
			remove(image, true);
			image.destroy();
			image = null;
		}
	}

	public function getTextDisplay():TextDisplay {
		
		if (tf != null) return tf; 
		
		tf = new TextDisplay();
		tf.parentComponent = asComponent;
		add(tf.tf);
		
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
		
		var intWidth = Std.int(width);
		var intHeight = Std.int(height);
		
		if (intWidth < 1) intWidth = 1;
		if (intHeight < 1) intHeight = 1;
		
		surface.makeGraphic(intWidth, intHeight, 0x0, true);
		
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
		
		if (left != null && asComponent.parentComponent != null) x = left + asComponent.parentComponent.x;
		if (top != null && asComponent.parentComponent != null) y = top + asComponent.parentComponent.y;
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
			FlxMouseEventManager.add(this, null, null, null, null, true, true, false);
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
			case MouseEvent.CLICK:
				FlxMouseEventManager.setMouseClickCallback(this, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_MOVE:
				FlxMouseEventManager.setMouseMoveCallback(this, __onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_WHEEL:
				FlxMouseEventManager.setMouseWheelCallback(this, __onMouseEvent.bind(type, listener));
		}
	}

	function unmapEvent(type:String, listener:UIEvent->Void) {
		
		if (!__mouseRegistered) return;
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxMouseEventManager.setMouseOverCallback(this, null);
			case MouseEvent.MOUSE_OUT:
				FlxMouseEventManager.setMouseOutCallback(this, null);
			case MouseEvent.MOUSE_DOWN:
				FlxMouseEventManager.setMouseDownCallback(this, null);
			case MouseEvent.MOUSE_UP:
				FlxMouseEventManager.setMouseUpCallback(this, null);
			case MouseEvent.CLICK:
				FlxMouseEventManager.setMouseClickCallback(this, null);
			case MouseEvent.MOUSE_MOVE:
				FlxMouseEventManager.setMouseMoveCallback(this, null);
			case MouseEvent.MOUSE_WHEEL:
				FlxMouseEventManager.setMouseWheelCallback(this, null);
		}
	}
	
	function __onMouseEvent(type:String, listener:UIEvent->Void, target:ComponentBase):Void {
		
		var me = new MouseEvent(type);
		me.target = cast target;
		me.screenX = FlxG.mouse.screenX;
		me.screenY = FlxG.mouse.screenY;
		me.buttonDown = FlxG.mouse.pressed;
		if (type == MouseEvent.MOUSE_WHEEL) me.delta = FlxG.mouse.wheel;
		listener(me);
	}
	
	override public function draw():Void {
		
		var screenLeft = Math.NaN;
		var screenTop = Math.NaN;
		
		if (dirty) {
			x = screenLeft = asComponent.screenLeft;
			y = screenTop = asComponent.screenTop;
		}
		
		if (tf != null && tf.tf.dirty) {
			
			if (Math.isNaN(screenLeft)) {
				screenLeft = asComponent.screenLeft;
				screenTop = asComponent.screenTop;
			}
			
			tf.tf.x = tf.left + screenLeft;
			tf.tf.y = tf.top + screenTop;
		}
		
		if (image != null && image.dirty) {
			
			if (Math.isNaN(screenLeft)) {
				screenLeft = asComponent.screenLeft;
				screenTop = asComponent.screenTop;
			}
			
			image.x = image.left + screenLeft;
			image.y = image.top + screenTop;
		}
		
		super.draw();
	}
}