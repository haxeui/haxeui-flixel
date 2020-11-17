package haxe.ui.backend;

import flixel.text.FlxText;
import haxe.ui.util.Color;

class TextDisplayImpl extends TextBase {
	public var tf:FlxText;
    
	public function new() {
		super();
		tf = new FlxText();
        tf.pixelPerfectPosition = true;
		tf.autoSize = true;
	}
    
    private override function validateData() {
        if (_text != null) {
            if (_dataSource == null) {
                tf.text = normalizeText(_text);
            }
        } else if (_htmlText != null) {
            var rules = [];
            var outText = processTags(_htmlText, rules);
            if (rules.length > 0) {
                tf.applyMarkup(outText, rules);
            } else {
                tf.text = normalizeText(_htmlText);
            }
        }
    }
    
    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;
		if (_textStyle != null) {
			if (_textStyle.textAlign != null) {
                //tf.autoSize = false;
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
    
    private function normalizeText(text:String):String {
        text = StringTools.replace(text, "\\n", "\n");
        return text;
    }
    
    private override function get_supportsHtml():Bool {
        return true;
    }
    
    private static function processTags(s:String, rules:Array<FlxTextFormatMarkerPair>) {
        var inTag:Bool = false;
        var endTag:Bool = false;
        var tagDetails = "";
        var out = "";
        
        var tagStack:Array<String> = [];
        var colorMap:Map<String, Int> = new Map<String, Int>();
        
        for (i in 0...s.length) {
            var c = s.charAt(i);
            switch (c) {
                case "<":
                    var temp = s.substring(i + 1, i + 6);
                    if (temp == "font " || temp == "/font") { // bit hacky!
                        inTag = true;
                        endTag = false;
                        tagDetails = "";
                    }
                case "/":
                    if (inTag == true) {
                        endTag = true;
                    }
                case ">":
                    if (inTag == true) {
                        if (endTag == false) {
                            var n = tagDetails.indexOf("color=");
                            if (n != -1) {
                                var col = tagDetails.substring(n + "color=".length);
                                col = StringTools.replace(col, "'", "");
                                col = StringTools.replace(col, "\"", "");
                                tagStack.push(col);
                                out += "<" + col + ">";
                                colorMap.set("<" + col + ">", Color.fromString(col));
                            } else {
                                tagStack.push(tagDetails);
                                out += tagDetails;
                            }
                            
                        } else {
                            var startTagDetails = tagStack.pop();
                            out += "<" + startTagDetails + ">";
                        }
                        inTag = false;
                    }
                default:
                    if (inTag == true) {
                        tagDetails += c.toLowerCase();
                    } else {
                        out += c;
                    }
            }
        }
        
        for (k in colorMap.keys()) {
            rules.push(new FlxTextFormatMarkerPair(new FlxTextFormat(colorMap.get(k)), k));
        }
        
        return out;
    }
}
