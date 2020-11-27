package haxe.ui.backend.flixel.textinputs;

import flixel.FlxG;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

class OpenFLTextInput extends TextBase {
    private var PADDING_X:Int = 4;
    private var PADDING_Y:Int = 0;
    
    public var tf:TextField;
    
    public function new() {
        super();
        tf = new TextField();
        tf.type = TextFieldType.INPUT;
        tf.selectable = true;
        tf.mouseEnabled = true;
        tf.autoSize = TextFieldAutoSize.NONE;
        tf.multiline = true;
        tf.wordWrap = true;
        //tf.stage.focus = null;
    }
    
    public function attach() {
        parentComponent.registerEvent(UIEvent.HIDDEN, onParentHidden);
        parentComponent.registerEvent(UIEvent.SHOWN, onParentShown);
    }
    
    private var _parentHidden:Bool = false;
    private function onParentHidden(e) {
        _parentHidden = true;
        tf.visible = false;
    }
    
    private function onParentShown(e) {
        _parentHidden = false;
        tf.visible = true;
    }
    
    public function update() {
        if (_parentHidden == true) {
            return;
        }
        
        var x1 = tf.x;
        var y1 = tf.y;
        var x2 = tf.x + tf.textWidth;
        var y2 = tf.y + tf.textHeight;
        
        var rc = new Rectangle(tf.x, tf.y, tf.textWidth, tf.textHeight); 
        
        var components:Array<Component> = [];
        var overlaps:Bool = false;
        for (r in Screen.instance.rootComponents) {
            if (parentComponent.rootComponent == r) {
                continue;
            }
            
            var rootRect = new Rectangle(r.screenLeft, r.screenTop, r.width, r.height);
            if (rootRect.intersects(rc)) {
                overlaps = true;
                break;
            }
        }
        /*
        trace(components.length);
        for (c in components) {
            trace(c.className);
        }
        */
        if (overlaps == true && tf.visible == true) {
            tf.visible = false;
        } else if (overlaps == false && tf.visible == false) {
            tf.visible = true;
        }
    }
    
    public function destroy() {
        FlxG.removeChild(tf);
        tf = null;
    }
    
    private override function validateData() {
        if (_text != null) {
            if (_dataSource == null) {
                tf.text = normalizeText(_text);
            }
        }
    }
    
    private function normalizeText(text:String):String {
        text = StringTools.replace(text, "\\n", "\n");
        return text;
    }
    
    private override function measureText() {
        tf.width = _width;
        
        #if !flash
        _textWidth = tf.textWidth + PADDING_X;
        //_textWidth = textField.textWidth + PADDING_X;
        #else
        //_textWidth = textField.textWidth - 2;
        #end
        _textHeight = tf.textHeight;
        if (_textHeight == 0) {
            var tmpText:String = tf.text;
            tf.text = "|";
            _textHeight = tf.textHeight;
            tf.text = tmpText;
        }
        #if !flash
        //_textHeight += PADDING_Y;
        #else
        //_textHeight -= 2;
        #end
        
        _textWidth = Math.round(_textWidth);
        _textHeight = Math.round(_textHeight);

        //////////////////////////////////////////////////////////////////////////////
        
        _inputData.hscrollMax = tf.maxScrollH;
        // see below
        _inputData.hscrollPageSize = (_width * _inputData.hscrollMax) / _textWidth;

        _inputData.vscrollMax = tf.maxScrollV;
        // cant have page size yet as there seems to be an openfl issue with bottomScrollV
        // https://github.com/openfl/openfl/issues/2220
        _inputData.vscrollPageSize = (_height * _inputData.vscrollMax) / _textHeight;
    }
    
    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;

        var format:TextFormat = tf.getTextFormat();

        if (_textStyle != null) {
            if (format.align != _textStyle.textAlign) {
                format.align = _textStyle.textAlign;
            }

            var fontSizeValue = Std.int(_textStyle.fontSize);
            if (_textStyle.fontSize == null) {
                //fontSizeValue = 13;
            }
            if (format.size != fontSizeValue) {
                format.size = fontSizeValue;

                measureTextRequired = true;
            }

            if (_fontInfo != null && format.font != _fontInfo.data) {
                format.font = _fontInfo.data;
                measureTextRequired = true;
            }

            if (format.color != _textStyle.color) {
                format.color = _textStyle.color;
            }
            
            if (format.bold != _textStyle.fontBold) {
                //format.bold = _textStyle.fontBold;
                measureTextRequired = true;
            }
            
            if (format.italic != _textStyle.fontItalic) {
                //format.italic = _textStyle.fontItalic;
                measureTextRequired = true;
            }
            
            if (format.underline != _textStyle.fontUnderline) {
                //format.underline = _textStyle.fontUnderline;
                measureTextRequired = true;
            }
        }

        tf.defaultTextFormat = format;
        tf.setTextFormat(format);
        if (tf.wordWrap != _displayData.wordWrap) {
            tf.wordWrap = _displayData.wordWrap;
            measureTextRequired = true;
        }

        if (tf.multiline != _displayData.multiline) {
            tf.multiline = _displayData.multiline;
            measureTextRequired = true;
        }

        return measureTextRequired;
    }
    
    private function onChange(e) {
        _text = tf.text;
        
        measureText();
        
        if (_inputData.onChangedCallback != null) {
            _inputData.onChangedCallback();
        }
    }
    
    private function onScroll(e) {
        _inputData.hscrollPos = tf.scrollH;
        _inputData.vscrollPos = tf.scrollV - 1;
        
        if (_inputData.onScrollCallback != null) {
            _inputData.onScrollCallback();
        }
    }
    
    private override function validatePosition() {
        _left = Math.round(_left);
        _top = Math.round(_top);
    }

    private override function validateDisplay() {
        if (tf.width != _width) {
            tf.width = _width;
        }

        if (tf.height != _height) {
            #if flash
            tf.height = _height;
            //textField.height = _height + 4;
            #else
            tf.height = _height;
            #end
        }
    }
}