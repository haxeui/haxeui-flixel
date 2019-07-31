package haxe.ui.backend;

import flixel.math.FlxRect;
import flixel.text.FlxText;
import haxe.ui.assets.FontInfo;
import haxe.ui.core.Component;
import haxe.ui.styles.Style;
import haxe.ui.core.TextDisplay.TextDisplayData;

class TextDisplayImpl extends TextBase {
	public var tf:FlxText;
	
	public function new() {
		super();
		tf = new FlxText();
		tf.autoSize = true;
	}
	
	override function validateData():Void {
		tf.text = _text;
	}
	
	override function validateStyle():Bool {
        var measureTextRequired:Bool = false;
		
		if (_textStyle != null) {
			
			if (_textStyle.textAlign != null) {
                tf.alignment = _textStyle.textAlign;
                measureTextRequired = true;
            }
			
			if (_textStyle.fontSize != null) {
                tf.size = Std.int(_textStyle.fontSize);
                measureTextRequired = true;
            }
			
			if (_fontInfo != null) {
                tf.font = _fontInfo.data;
                measureTextRequired = true;
            }
			
			if (_textStyle.fontBold != null) {
                tf.bold = _textStyle.fontBold;
                measureTextRequired = true;
            }
            
			if (_textStyle.fontItalic != null) {
                tf.italic = _textStyle.fontItalic;
                measureTextRequired = true;
            }
			// if (_textStyle.fontUnderline != null) tf.underline = _textStyle.fontUnderline;
			
			if (_textStyle.color != null) {
                tf.color = _textStyle.color;
            }
			
			if (tf.wordWrap != _displayData.wordWrap) {
                tf.wordWrap = _displayData.wordWrap;
                tf.autoSize = !_displayData.wordWrap;
                measureTextRequired = true;
            }
			if (tf.textField.multiline != _displayData.multiline) {
                tf.textField.multiline = _displayData.multiline;
                tf.autoSize = !_displayData.multiline;
                measureTextRequired = true;
            }
			
			tf.drawFrame(true); // see if this needs to be called each time
		}
		
		return measureTextRequired;
	}
	
	override  function validatePosition():Void {
    }
	
	override function validateDisplay():Void {
		//if (!tf.autoSize) {
			if (tf.textField.width != _width) tf.textField.width = _width;
			if (tf.textField.height != _height) tf.textField.height = _height;
		//}
	}
	
	override function measureText():Void {
        #if html5
		_textWidth = tf.textField.textWidth + 2;
		_textHeight = tf.textField.textHeight + 2;
        #else
		_textWidth = tf.textField.textWidth + 4;
		_textHeight = tf.textField.textHeight + 4;
        #end
	}
}