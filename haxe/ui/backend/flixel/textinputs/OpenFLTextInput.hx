package haxe.ui.backend.flixel.textinputs;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.ui.Toolkit;
import haxe.ui.backend.TextInputImpl.TextInputEvent;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Rectangle;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;

class OpenFLTextInput extends TextBase {
    public static var USE_ON_ADDED:Bool = true;
    public static var USE_ON_REMOVED:Bool = true;

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
        tf.tabEnabled = false;
        //tf.stage.focus = null;
        tf.addEventListener(Event.CHANGE, onInternalChange);
        _inputData.vscrollPageStep = 1;
        _inputData.vscrollNativeWheel = true;
    }
    
    public override function focus() {
        if (tf.stage != null) {
            //tf.stage.focus = tf;
        }
    }
    
    public override function blur() {
        if (tf.stage != null) {
            //tf.stage.focus = null;
        }
    }
    
    public function attach() {
    }
    
    public var visible(get, set):Bool;
    private function get_visible():Bool {
        return tf.visible;
    }
    private function set_visible(value:Bool):Bool {
        tf.visible = value;
        return value;
    }

    public var x(get, set):Float;
    private function get_x():Float {
        return tf.x;
    }
    private function set_x(value:Float):Float {
        tf.x = value * FlxG.scaleMode.scale.x;
        return value;
    }

    public var y(get, set):Float;
    private function get_y():Float {
        return tf.y;
    }
    private function set_y(value:Float):Float {
        tf.y = value * FlxG.scaleMode.scale.y;
        return value;
    }

    public var scaleX(get, set):Float;
    private function get_scaleX():Float {
        return tf.scaleX;
    }
    private function set_scaleX(value:Float):Float {
        tf.scaleX = value;
        return value;
    }

    public var scaleY(get, set):Float;
    private function get_scaleY():Float {
        return tf.scaleY;
    }
    private function set_scaleY(value:Float):Float {
        tf.scaleY = value;
        return value;
    }

    public var alpha(get, set):Float;
    private function get_alpha():Float {
        return tf.alpha;
    }
    private function set_alpha(value:Float):Float {
        tf.alpha = value;
        return value;
    }


    private var _onMouseDown:TextInputEvent->Void = null;
    public var onMouseDown(null, set):TextInputEvent->Void;
    private function set_onMouseDown(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onMouseDown != null) {
            tf.removeEventListener(openfl.events.MouseEvent.MOUSE_DOWN, __onTextInputMouseDownEvent);
        }
        _onMouseDown = value;
        if (_onMouseDown != null) {
            tf.addEventListener(openfl.events.MouseEvent.MOUSE_DOWN, __onTextInputMouseDownEvent);
        }
        return value;
    }

    private function __onTextInputMouseDownEvent(event:openfl.events.MouseEvent) {
        if (_onMouseDown != null) {
            _onMouseDown({
                type: event.type,
                stageX: event.stageX,
                stageY: event.stageY
            });
        }
    }

    private var _onMouseUp:TextInputEvent->Void = null;
    public var onMouseUp(null, set):TextInputEvent->Void;
    private function set_onMouseUp(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onMouseUp != null) {
            tf.removeEventListener(openfl.events.MouseEvent.MOUSE_UP, __onTextInputMouseUpEvent);
        }
        _onMouseUp = value;
        if (_onMouseUp != null) {
            tf.addEventListener(openfl.events.MouseEvent.MOUSE_UP, __onTextInputMouseUpEvent);
        }
        return value;
    }

    private function __onTextInputMouseUpEvent(event:openfl.events.MouseEvent) {
        if (_onMouseUp != null) {
            _onMouseUp({
                type: event.type,
                stageX: event.stageX,
                stageY: event.stageY
            });
        }
    }

    private var _onClick:TextInputEvent->Void = null;
    public var onClick(null, set):TextInputEvent->Void;
    private function set_onClick(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onClick != null) {
            tf.removeEventListener(openfl.events.MouseEvent.CLICK, __onTextInputClickEvent);
        }
        _onClick = value;
        if (_onClick != null) {
            tf.addEventListener(openfl.events.MouseEvent.CLICK, __onTextInputClickEvent);
        }
        return value;
    }

    private function __onTextInputClickEvent(event:openfl.events.MouseEvent) {
        if (_onClick != null) {
            _onClick({
                type: event.type,
                stageX: event.stageX,
                stageY: event.stageY
            });
        }
    }

    private var _onChange:TextInputEvent->Void = null;
    public var onChange(null, set):TextInputEvent->Void;
    private function set_onChange(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onChange != null) {
            tf.removeEventListener(Event.CHANGE, __onTextInputChangeEvent);
        }
        _onChange = value;
        if (_onChange != null) {
            tf.addEventListener(Event.CHANGE, __onTextInputChangeEvent);
        }
        return value;
    }

    private function __onTextInputChangeEvent(event:Event) {
        if (_onChange != null) {
            _onChange({
                type: event.type,
                stageX: 0,
                stageY: 0
            });
        }
    }

    private var _onKeyDown:KeyboardEvent->Void = null;
    public var onKeyDown(null, set):KeyboardEvent->Void;
    private function set_onKeyDown(value:KeyboardEvent->Void):KeyboardEvent->Void {
        if (_onKeyDown != null) {
            tf.removeEventListener(KeyboardEvent.KEY_DOWN, __onTextInputKeyDown);
        }
        _onKeyDown = value;
        if (_onKeyDown != null) {
            tf.addEventListener(KeyboardEvent.KEY_DOWN, __onTextInputKeyDown);
        }
        return value;
    }

    private function __onTextInputKeyDown(e:KeyboardEvent) {
        if (_onKeyDown != null)
            _onKeyDown(e);
    }

    private var _onKeyUp:KeyboardEvent->Void = null;
    public var onKeyUp(null, set):KeyboardEvent->Void;
    private function set_onKeyUp(value:KeyboardEvent->Void):KeyboardEvent->Void {
        if (_onKeyUp != null) {
            tf.removeEventListener(KeyboardEvent.KEY_UP, __onTextInputKeyUp);
        }
        _onKeyUp = value;
        if (_onKeyUp != null) {
            tf.addEventListener(KeyboardEvent.KEY_UP, __onTextInputKeyUp);
        }
        return value;
    }

    private function __onTextInputKeyUp(e:KeyboardEvent) {
        if (_onKeyUp != null)
            _onKeyUp(e);
    }

    public function addToComponent(component:Component) {
        FlxG.addChildBelowMouse(tf, 0xffffff);
    }

    public function equals(sprite:FlxSprite):Bool {
        return false;
    }

    private var _parentHidden:Bool = false;
    public function update() {
        var ref = parentComponent;
        // TODO: perf?
        while (ref != null) {
            if (ref.hidden) {
                tf.visible = false;
                _parentHidden = true;
                break;
            }
            ref = ref.parentComponent;
        }

        if (_parentHidden == true) {
            return;
        }

        tf.visible = true;
        
        var x1 = tf.x;
        var y1 = tf.y;
        var x2 = tf.x + tf.textWidth;
        var y2 = tf.y + tf.textHeight;
        
        var rc = new Rectangle(tf.x, tf.y, tf.textWidth, tf.textHeight); 
        
        var components:Array<Component> = [];
        var overlaps:Bool = false;
        var after = false;
        for (r in Screen.instance.rootComponents) {
            if (parentComponent.rootComponent == r) {
                after = true;
                continue;
            }
            
            var rootRect = new Rectangle(r.screenLeft, r.screenTop, r.width, r.height);
            if (after == true && rootRect.intersects(rc)) {
                overlaps = true;
                break;
            }
        }

        /*
        if (overlaps == true && tf.visible == true) {
            tf.visible = false;
        } else if (overlaps == false && tf.visible == false) {
            tf.visible = true;
        }
        */
    }
    
    public function destroy(component:Component) {
        _parentHidden = true;
        tf.visible = false;
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
        tf.width = _width * Toolkit.scaleX;
        
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
        
        _textWidth = Math.round(_textWidth) / Toolkit.scaleX;
        _textHeight = Math.round(_textHeight) / Toolkit.scaleY;

        //////////////////////////////////////////////////////////////////////////////
        
        _inputData.hscrollMax = tf.maxScrollH;
        // see below
        _inputData.hscrollPageSize = (_width * _inputData.hscrollMax) / _textWidth;

        _inputData.vscrollMax = tf.maxScrollV - 1;
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
                format.size = Std.int(fontSizeValue * Toolkit.scale);

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

        if (tf.displayAsPassword != _inputData.password) {
            tf.displayAsPassword = _inputData.password;
        }

        tf.type = (parentComponent.disabled ? DYNAMIC : INPUT);
        
        return measureTextRequired;
    }
    
    private function onInternalChange(e:Event) {
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
        _left = Math.round(_left * Toolkit.scaleX);
        _top = Math.round(_top * Toolkit.scaleY);
    }

    private override function validateDisplay() {
        if (tf.width != _width * Toolkit.scaleX) {
            tf.width = _width * Toolkit.scaleX;
        }

        if (tf.height != _height * Toolkit.scaleY) {
            #if flash
            tf.height = _height * Toolkit.scaleY;
            //textField.height = _height + 4;
            #else
            tf.height = _height * Toolkit.scaleY;
            #end
        }
    }
}