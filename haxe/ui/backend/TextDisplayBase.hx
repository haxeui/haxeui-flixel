package haxe.ui.backend;

import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextFormat;
import haxe.ui.assets.FontInfo;
import haxe.ui.core.Component;
import haxe.ui.styles.Style;

class TextDisplayBase {
	
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
	var _multiline:Bool = true;
	var _wordWrap:Bool = true;
	var _fontInfo:FontInfo;
	
	var format:FlxTextFormat;
	
	public function new() {
		
		tf = new FlxText();
		format = new FlxTextFormat();
		
		tf.addFormat(format);
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
			if (_textStyle.fontItalic != null) tf.bold = _textStyle.fontItalic;
			if (_textStyle.fontUnderline != null) tf.bold = _textStyle.fontUnderline;
			
			if (_textStyle.color != null) tf.color = _textStyle.color;
			
			tf.wordWrap = _wordWrap;
			
			if (tf.textField.multiline != _multiline) tf.textField.multiline = _multiline;
		}
		
		return true;
	}
	
	public function validatePosition():Void { }
	
	function validateDisplay():Void {
		
		if (tf.fieldWidth != _width) tf.fieldWidth = _width;
		if (tf.textField.height != _height) tf.textField.height = _height;
	}
	
	function measureText():Void {
		_textWidth = tf.textField.textWidth;
		_textHeight = tf.textField.textHeight;
	}
}