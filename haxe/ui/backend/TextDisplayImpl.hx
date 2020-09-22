package haxe.ui.backend;

import flixel.text.FlxText;

class TextDisplayImpl extends TextBase {
	public var tf:FlxText;
    
	public function new() {
		super();
		tf = new FlxText();
        tf.pixelPerfectPosition = true;
		tf.autoSize = true;
	}
    
    private override function validateData() {
        tf.text = _text;
    }
    
    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;
		
		if (_textStyle != null) {
			
			if (_textStyle.textAlign != null) {
                tf.autoSize = false;
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
                //tf.autoSize = !_displayData.wordWrap;
                measureTextRequired = true;
            }
			if (tf.textField.multiline != _displayData.multiline) {
                tf.textField.multiline = _displayData.multiline;
                //tf.autoSize = !_displayData.multiline;
                measureTextRequired = true;
            }
			
			tf.drawFrame(true); // see if this needs to be called each time
		}
		
		return measureTextRequired;
    }
    
    private override function validateDisplay() {
        if (tf.textField.width != _width) {
            tf.textField.width = _width;
        }
        if (tf.textField.height != _height) {
            tf.textField.height = _height;
        }
    }
    
    private override function measureText() {
		_textWidth = Math.fround(tf.textField.textWidth) + 2;
		_textHeight = Math.fround(tf.textField.textHeight);
    }
}
