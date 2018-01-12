package haxe.ui.backend;

import flixel.math.FlxRect;
import flixel.text.FlxText;
import haxe.ui.assets.FontInfo;
import haxe.ui.core.Component;
import haxe.ui.styles.Style;
import haxe.ui.core.TextDisplay.TextDisplayData;

class TextDisplayBase {
	private var _displayData:TextDisplayData = new TextDisplayData();

	public var parentComponent:Component;
	public var tf:FlxText;
	
	var _left:Float = 0;
	var _top:Float = 0;
	var _width:Float = 100;
	var _height:Float = 0;
	
	var _text:String = "";
	var _textWidth:Float = 0;
	var _textHeight:Float = 0;
	
	var _textStyle:Style;
	var _fontInfo:FontInfo;
	
	public function new() {
		
		tf = new FlxText();
		tf.autoSize = true;
	}
	
	function validateData():Void {
		tf.text = _text;
	}
	
	function validateStyle():Bool {
		
		if (_textStyle != null) {
			
			if (_textStyle.textAlign != null) tf.alignment = _textStyle.textAlign;
			
			if (_textStyle.fontSize != null) tf.size = Std.int(_textStyle.fontSize);
			
			if (_fontInfo != null) tf.font = _fontInfo.data;
			
			if (_textStyle.fontBold != null) tf.bold = _textStyle.fontBold;
			if (_textStyle.fontItalic != null) tf.italic = _textStyle.fontItalic;
			// if (_textStyle.fontUnderline != null) tf.underline = _textStyle.fontUnderline;
			
			if (_textStyle.color != null) tf.color = _textStyle.color;
			
			if (_textStyle.width != null) tf.fieldWidth = tf.width = _textStyle.width;
			if (_textStyle.height != null) tf.textField.height = tf.height = _textStyle.height;
			
			if (tf.wordWrap != _displayData.wordWrap) tf.wordWrap = _displayData.wordWrap;
			if (tf.textField.multiline != _displayData.multiline) tf.textField.multiline = _displayData.multiline;
			
			tf.drawFrame(true); // see if this needs to be called each time
		}
		
		return true;
	}
	
	public function validatePosition():Void { }
	
	function validateDisplay():Void {
		
		if (!tf.autoSize) {
			if (tf.fieldWidth != _width) tf.fieldWidth = _width;
			if (tf.textField.height != _height) tf.textField.height = _height;
		}
	}
	
	function measureText():Void {
		_textWidth = tf.textField.textWidth;
		_textHeight = tf.textField.textHeight;
	}
}