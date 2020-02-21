package haxe.ui.backend;

import openfl.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import haxe.ui.backend.flixel.FlxStyleHelper;
import haxe.ui.backend.flixel.FlxUIMouseEventManager;
import haxe.ui.core.Component;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.styles.Style;

class ComponentImpl extends ComponentBase {
	
	public var pixels(default, null):BitmapData;
	
	public function new() {
		super();
		scrollFactor.set(0, 0); // ui doesn't scroll by default
		
		handleSize(1, 1, null);
	}
	
	private override function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {
		
		var intWidth = Std.int(width);
		var intHeight = Std.int(height);
		
		if (intWidth < 1) intWidth = 1;
		if (intHeight < 1) intHeight = 1;
		
		var graphic = FlxG.bitmap.create(intWidth, intHeight, 0x0, true);
		graphic.persist = true;
		pixels = graphic.bitmap;
		
		// if (clipRect != null) surface.clipRect = clipRect;
		
		if (style != null) applyStyle(pixels, style);
	}
	
	private override function handleClipRect(value:Rectangle):Void {
		if (value == null) clipRect = null;
		else clipRect = FlxRect.get(value.left, value.top, value.width, value.height);
	}
	
	private override function handleVisibility(show:Bool):Void {
		super.handleVisibility(show);
		visible = show;
	}
	
	private override function applyStyle(style:Style) {
		FlxStyleHelper.applyStyle(pixels, style);
	}
	
	//***********************************************************************************************************
	// Event handling
	//***********************************************************************************************************
	
	var mouseRegistered:Bool = false;
	var eventMapping:Map<String, Bool> = [
		MouseEvent.MOUSE_OVER => false,
		MouseEvent.MOUSE_OUT => false,
		MouseEvent.MOUSE_DOWN => false,
		MouseEvent.MOUSE_UP => false,
		MouseEvent.CLICK => false,
		MouseEvent.MOUSE_MOVE => false,
		MouseEvent.MOUSE_WHEEL => false,
	];
	
	private override function mapEvent(type:String, listener:UIEvent->Void) {
		
		if (!mouseRegistered) {
			
			if (!eventMapping.exists(type)) return; // prevents something like a RESIZE event from registering the object in FlxMEM
			
			FlxUIMouseEventManager.add(this, null, null, null, null, true, true, false);
			mouseRegistered = true;
			
			// TODO: need to handle if an onscreen component gets its first mouse event here
			// TODO: check if the above todo is still relevant...
		}
		
		else if (eventMapping.get(type)) return;
		
		eventMapping.set(type, true);
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxUIMouseEventManager.setMouseOverCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_OUT:
				FlxUIMouseEventManager.setMouseOutCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_DOWN:
				FlxUIMouseEventManager.setMouseDownCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_UP:
				FlxUIMouseEventManager.setMouseUpCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.CLICK:
				FlxUIMouseEventManager.setMouseClickCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_MOVE:
				FlxUIMouseEventManager.setMouseMoveCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_WHEEL:
				FlxUIMouseEventManager.setMouseWheelCallback(this, onMouseEvent.bind(type, listener));
		}
	}
	
	private override function unmapEvent(type:String, listener:UIEvent->Void) {
		
		if (!mouseRegistered || !eventMapping.get(type)) return;
		
		eventMapping.set(type, false);
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxUIMouseEventManager.setMouseOverCallback(this, null);
			case MouseEvent.MOUSE_OUT:
				FlxUIMouseEventManager.setMouseOutCallback(this, null);
			case MouseEvent.MOUSE_DOWN:
				FlxUIMouseEventManager.setMouseDownCallback(this, null);
			case MouseEvent.MOUSE_UP:
				FlxUIMouseEventManager.setMouseUpCallback(this, null);
			case MouseEvent.CLICK:
				FlxUIMouseEventManager.setMouseClickCallback(this, null);
			case MouseEvent.MOUSE_MOVE:
				FlxUIMouseEventManager.setMouseMoveCallback(this, null);
			case MouseEvent.MOUSE_WHEEL:
				FlxUIMouseEventManager.setMouseWheelCallback(this, null);
		}
	}
	
	private function onMouseEvent(type:String, listener:UIEvent->Void, target:ComponentImpl):Void {
		
		var me = new MouseEvent(type);
		me.target = cast target;
		me.screenX = FlxG.mouse.screenX;
		me.screenY = FlxG.mouse.screenY;
		me.buttonDown = FlxG.mouse.pressed;
		if (type == MouseEvent.MOUSE_WHEEL) me.delta = FlxG.mouse.wheel;
		listener(me);
	}
	
	//***********************************************************************************************************
	// Flixel overrides
	//***********************************************************************************************************
	
	override public function destroy():Void {
		super.destroy();
		
		if (mouseRegistered) {
			FlxUIMouseEventManager.remove(this);
			mouseRegistered = false;
		}
		
		if (_imageDisplay != null) _imageDisplay.destroy();
		_imageDisplay = null;
		if (_textDisplay != null) _textDisplay.tf.destroy();
		_textDisplay = null;
		if (_textInput != null) _textInput.tf.destroy();
		_textInput = null;
	}
	
	override public function draw():Void {
		
		// need camera
		// drawSimple/Complex to camera
		
		if (!visible) return;
		
		// dirty flag, redo styling?
		
		for (camera in cameras) {
			
			if (!camera.visible || !camera.exists || !isOnScreen(camera)) continue;
		}
	}
	
	override public function update(dt:Float):Void {
		super.update();
		
	}
	
	
}