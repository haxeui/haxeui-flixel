package haxe.ui.backend;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
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
	var input:TextInput;
	
	var asComponent:Component = cast this;
	
	public function new() {
		super();
		
		scrollFactor.set(0, 0); // ui doesn't scroll by default
		
		surface = new FlxSprite();
		surface.makeGraphic(1, 1, 0x0, true);
		add(surface);
	}
	
	//***********************************************************************************************************
	// Text
	//***********************************************************************************************************
	
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
		
		if (input != null) return input;
		
		input = new TextInput();
		input.parentComponent = asComponent;
		add(input.tf);
		
		return input;
	}
	
	public function hasTextInput():Bool {
		return input != null;
	}
	
	//***********************************************************************************************************
	// Image
	//***********************************************************************************************************
	
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
	
	//***********************************************************************************************************
	// Display list management
	//***********************************************************************************************************
	
	function handleReady() { }
	
	function handleCreate(native:Bool):Void { }
	
	function handleAddComponent(child:Component):Component {
		add(child);
		return child;
	}
	
	function handleAddComponentAt(child:Component, index:Int):Component {
		
		// index is in terms of haxeui components, not flixel children
		
		var indexOffset = 0;
		
		while (indexOffset < members.length) {
			if (!Std.is(members[indexOffset], Component)) indexOffset++;
			else break;
		}
		
		insert(index + indexOffset, child);
		return child;
	}
	
	function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
		if (members.indexOf(child) > -1) remove(child, true);
		return child;
	}
	
	function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
		return handleRemoveComponent(asComponent.childComponents[index], dispose);
	}
	
	function handleSetComponentIndex(child:Component, index:Int):Void {
		handleAddComponentAt(child, index);
	}
	
	function handlePosition(left:Null<Float>, top:Null<Float>, style:Style):Void {
		
		if (left != null) {
			
			x = asComponent.left = left;
			
			if (asComponent.parentComponent != null) x += asComponent.parentComponent.x;
			if (asComponent.componentClipRect != null) x -= asComponent.componentClipRect.left;
		}
		
		if (top != null) {
			
			y = asComponent.top = top;
			
			if (asComponent.parentComponent != null) y += asComponent.parentComponent.y;
			if (asComponent.componentClipRect != null) y -= asComponent.componentClipRect.top;
		}
	}
	
	function handlePreReposition() { }
	
	function handlePostReposition() { }
	
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
	
	function handleVisibility(show:Bool):Void {
		visible = show;
	}
	
	function applyStyle(style:Style) {
		FlxStyleHelper.applyStyle(surface, style);
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
	
	function mapEvent(type:String, listener:UIEvent->Void) {
		
		if (!mouseRegistered) {
			FlxMouseEventManager.add(this, null, null, null, null, true, true, false);
			mouseRegistered = true;
		}
		
		else if (eventMapping.get(type)) return;
		
		eventMapping.set(type, true);
		
		switch (type) {
			case MouseEvent.MOUSE_OVER:
				FlxMouseEventManager.setMouseOverCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_OUT:
				FlxMouseEventManager.setMouseOutCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_DOWN:
				FlxMouseEventManager.setMouseDownCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_UP:
				FlxMouseEventManager.setMouseUpCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.CLICK:
				FlxMouseEventManager.setMouseClickCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_MOVE:
				FlxMouseEventManager.setMouseMoveCallback(this, onMouseEvent.bind(type, listener));
			case MouseEvent.MOUSE_WHEEL:
				FlxMouseEventManager.setMouseWheelCallback(this, onMouseEvent.bind(type, listener));
		}
	}
	
	function unmapEvent(type:String, listener:UIEvent->Void) {
		
		if (!mouseRegistered || !eventMapping.get(type)) return;
		
		eventMapping.set(type, false);
		
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
	
	function onMouseEvent(type:String, listener:UIEvent->Void, target:ComponentBase):Void {
		
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
			FlxMouseEventManager.remove(this);
			mouseRegistered = false;
		}
		
		if (surface != null) surface.destroy();
		surface = null;
		if (image != null) image.destroy();
		image = null;
		if (tf != null) tf.tf.destroy();
		tf = null;
		if (input != null) input.tf.destroy();
		input = null;
		
		asComponent = null;
	}
	
	// some extra child management needs to occur
	override public function draw():Void {
		
		var screenLeft = Math.NaN;
		var screenTop = Math.NaN;
		
		if (dirty) {
			
			screenLeft = asComponent.screenLeft;
			screenTop = asComponent.screenTop;
			
			if (x != screenLeft || y != screenTop) {
				x = screenLeft;
				y = screenTop;
			}
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
		
		if (input != null && input.tf.dirty) {
			
			if (Math.isNaN(screenLeft)) {
				screenLeft = asComponent.screenLeft;
				screenTop = asComponent.screenTop;
			}
			
			input.tf.x = input.left + screenLeft;
			input.tf.y = input.top + screenTop;
		}
		
		super.draw();
	}
	
	// Flixel uses width/height for the hitbox, but HaxeUI uses them graphically
	// This is an issue when it comes to clipRects, so we have to override the overlap functions that mouse events use
	override public function overlapsPoint(point:FlxPoint, inScreenSpace:Bool = true, ?camera:FlxCamera):Bool {
		
		var result:Bool = false;
		for (sprite in _sprites)
		{
			if (sprite != null && sprite.exists && sprite.visible)
			{
				if (sprite.flixelType == SPRITEGROUP) result = sprite.overlapsPoint(point, inScreenSpace, camera);
				else result = overlapsPointHelper(sprite, point, inScreenSpace, camera);
			}
			
			if (result) return true;
		}
		
		return false;
	}
	
	// This is essentially overriding FlxSprite's overlapsPoint for use with clipRects
	// Not its intended functionality, but hey
	function overlapsPointHelper(sprite:FlxSprite, point:FlxPoint, inScreenSpace:Bool = true, ?camera:FlxCamera):Bool {
		
		// does not account for offset, which isn't used in the backend anyway
		
		var rect:FlxRect;
		
		if (sprite.clipRect == null) rect = FlxRect.get(sprite.x, sprite.y, sprite.width, sprite.height);
		
		else {
			rect = FlxRect.get();
			rect.copyFrom(sprite._frame.frame);
			rect.x += sprite.x;	rect.y += sprite.y;
		}
		
		var xx = point.x;
		var yy = point.y;
		
		point.putWeak();
		
		if (inScreenSpace) {
			
			if (camera == null) camera = FlxG.camera;
			
			xx -= camera.scroll.x;
			yy -= camera.scroll.y;
			
			if (sprite.pixelPerfectPosition) rect.floor(); // is flooring wh ok?
			
			rect.x -= camera.scroll.x * sprite.scrollFactor.x;
			rect.y -= camera.scroll.y * sprite.scrollFactor.y;
		}
		
		var ret = xx >= rect.left && xx < rect.right && yy >= rect.top && yy < rect.bottom;
		
		rect.put();
		
		return ret;
	}
}