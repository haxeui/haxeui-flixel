package haxe.ui.backend.flixel.textinputs;

import flixel.FlxSprite;
import haxe.ui.backend.TextInputImpl.TextInputEvent;
import haxe.ui.core.Component;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

#if flixel_text_input

class FlxTextInput extends TextBase {
    public static var USE_ON_ADDED:Bool = false;
    public static var USE_ON_REMOVED:Bool = false;

    private static inline var PADDING_X:Int = 4;
    private static inline var PADDING_Y:Int = 2;

    private var tf:flixel.addons.text.FlxTextInput;

    public function new() {
        super();
        tf = new flixel.addons.text.FlxTextInput();
        tf.onChange.add(onInternalChange);
        tf.onScroll.add(onScroll);
        tf.pixelPerfectRender = true;
        tf.moves = false;
        _inputData.vscrollPageStep = 1;
        _inputData.vscrollNativeWheel = true;
    }

    public override function focus() {
        tf.focus = true;
    }
    
    public override function blur() {
        tf.focus = false;
    }

    public function attach() {
    }
    
    public var visible(get, set):Bool;
    private function get_visible():Bool {
        return tf.visible;
    }
    private function set_visible(value:Bool):Bool {
        tf.active = tf.visible = value; // text input shouldn't be active if it's hidden
        return value;
    }

    public var x(get, set):Float;
    private function get_x():Float {
        return tf.x;
    }
    private function set_x(value:Float):Float {
        tf.x = value;
        return value;
    }

    public var y(get, set):Float;
    private function get_y():Float {
        return tf.y;
    }
    private function set_y(value:Float):Float {
        tf.y = value;
        return value;
    }

    public var scaleX(get, set):Float;
    private function get_scaleX():Float {
        return tf.scale.x;
    }
    private function set_scaleX(value:Float):Float {
        // do nothing
        return value;
    }

    public var scaleY(get, set):Float;
    private function get_scaleY():Float {
        return tf.scale.y;
    }
    private function set_scaleY(value:Float):Float {
        // do nothing
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

    private override function validateData() {
        if (_text != null) {
            if (_dataSource == null) {
                tf.text = normalizeText(_text);
            }
        }

        var hscrollValue = Std.int(_inputData.hscrollPos);
        if (tf.scrollH != hscrollValue) {
            tf.scrollH = hscrollValue;
        }

        var vscrollValue = Std.int(_inputData.vscrollPos) + 1;
        if (tf.scrollV != vscrollValue) {
            tf.scrollV = vscrollValue;
        }
    }
    
    private function normalizeText(text:String):String {
        text = StringTools.replace(text, "\\n", "\n");
        return text;
    }

    private override function measureText() {
        //tf.width = _width * Toolkit.scaleX;
        _textHeight = tf.textField.textHeight;
        if (_textHeight == 0) {
            var tmpText:String = tf.text;
            tf.text = "|";
            _textHeight = tf.textField.textHeight;
            tf.text = tmpText;
        }

        _textWidth = Math.round(_textWidth) / Toolkit.scaleX;
        _textHeight = Math.round(_textHeight) / Toolkit.scaleY;

        //////////////////////////////////////////////////////////////////////////////
        
        _inputData.hscrollMax = tf.maxScrollH;
        // see below
        _inputData.hscrollPageSize = (_width * _inputData.hscrollMax) / _textWidth;

        _inputData.vscrollMax = tf.maxScrollV - 1;
        _inputData.vscrollPageSize = (_height * _inputData.vscrollMax) / _textHeight;
    }

    private override function validateStyle():Bool {
        var measureTextRequired:Bool = false;

        if (_textStyle != null) {
            var textAlign = (_textStyle.textAlign != null ? _textStyle.textAlign : "left");
            if (tf.alignment != textAlign) {
                tf.alignment = textAlign;
            }

            var fontSizeValue = Std.int(_textStyle.fontSize);
            if (tf.size != fontSizeValue) {
                tf.size = Std.int(fontSizeValue * Toolkit.scale);

                measureTextRequired = true;
            }

            if (_fontInfo != null && tf.font != _fontInfo.data) {
                tf.font = _fontInfo.data;
                measureTextRequired = true;
            }

            if (tf.color != _textStyle.color) {
                tf.color = _textStyle.color;
            }

            var fontBold = (_textStyle.fontBold != null ? _textStyle.fontBold : false);
            if (tf.bold != fontBold) {
                tf.bold = fontBold;
                measureTextRequired = true;
            }
            
            var fontItalic = (_textStyle.fontItalic != null ? _textStyle.fontItalic : false);
            if (tf.italic != fontItalic) {
                tf.italic = fontItalic;
                measureTextRequired = true;
            }
        }

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

    private override function validatePosition() {
        _left = Math.round(_left * Toolkit.scaleX);
        _top = Math.round(_top * Toolkit.scaleY) + (PADDING_Y / 2);
    }

    private override function validateDisplay() {
        if (_width <= 0 || _height <= 0) {
            return;
        }

        if (tf.width != _width * Toolkit.scaleX) {
            tf.width = _width * Toolkit.scaleX;
            tf.fieldWidth = tf.width;
        }

        if (tf.height != (_height + PADDING_Y) * Toolkit.scaleY) {
            tf.height = (_height + PADDING_Y) * Toolkit.scaleY;
            tf.fieldHeight = tf.height;
        }
    }

    private var _onMouseDown:TextInputEvent->Void = null;
    public var onMouseDown(null, set):TextInputEvent->Void;
    private function set_onMouseDown(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onMouseDown != null) {
            //tf.removeEventListener(openfl.events.MouseEvent.MOUSE_DOWN, __onTextInputMouseDownEvent);
        }
        _onMouseDown = value;
        if (_onMouseDown != null) {
            //tf.addEventListener(openfl.events.MouseEvent.MOUSE_DOWN, __onTextInputMouseDownEvent);
        }
        return value;
    }

    /*
    private function __onTextInputMouseDownEvent(event:openfl.events.MouseEvent) {
        if (_onMouseDown != null) {
            _onMouseDown({
                type: event.type,
                stageX: event.stageX,
                stageY: event.stageY
            });
        }
    }
    */

    private var _onMouseUp:TextInputEvent->Void = null;
    public var onMouseUp(null, set):TextInputEvent->Void;
    private function set_onMouseUp(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onMouseUp != null) {
            //tf.removeEventListener(openfl.events.MouseEvent.MOUSE_UP, __onTextInputMouseUpEvent);
        }
        _onMouseUp = value;
        if (_onMouseUp != null) {
            //tf.addEventListener(openfl.events.MouseEvent.MOUSE_UP, __onTextInputMouseUpEvent);
        }
        return value;
    }

    /*
    private function __onTextInputMouseUpEvent(event:openfl.events.MouseEvent) {
        if (_onMouseUp != null) {
            _onMouseUp({
                type: event.type,
                stageX: event.stageX,
                stageY: event.stageY
            });
        }
    }
    */

    public function equals(sprite:FlxSprite):Bool {
        return sprite == tf;
    }

    private var _onClick:TextInputEvent->Void = null;
    public var onClick(null, set):TextInputEvent->Void;
    private function set_onClick(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onClick != null) {
            //tf.removeEventListener(openfl.events.MouseEvent.CLICK, __onTextInputClickEvent);
        }
        _onClick = value;
        if (_onClick != null) {
            //tf.addEventListener(openfl.events.MouseEvent.CLICK, __onTextInputClickEvent);
        }
        return value;
    }

    /*
    private function __onTextInputClickEvent(event:openfl.events.MouseEvent) {
        if (_onClick != null) {
            _onClick({
                type: event.type,
                stageX: event.stageX,
                stageY: event.stageY
            });
        }
    }
    */

    private var _onChange:TextInputEvent->Void = null;
    public var onChange(null, set):TextInputEvent->Void;
    private function set_onChange(value:TextInputEvent->Void):TextInputEvent->Void {
        if (_onChange != null) {
            tf.onChange.remove(__onTextInputChangeEvent);
        }
        _onChange = value;
        if (_onChange != null) {
            tf.onChange.add(__onTextInputChangeEvent);
        }
        return value;
    }

    private function __onTextInputChangeEvent() {
        if (_onChange != null) {
            _onChange({
                type: "change",
                stageX: 0,
                stageY: 0
            });
        }
    }

    private var _onKeyDown:KeyboardEvent->Void = null;
    public var onKeyDown(null, set):KeyboardEvent->Void;
    private function set_onKeyDown(value:KeyboardEvent->Void):KeyboardEvent->Void {
        if (_onKeyDown != null) {
            //tf.textField.removeEventListener(KeyboardEvent.KEY_DOWN, __onTextInputKeyDown);
        }
        _onKeyDown = value;
        if (_onKeyDown != null) {
            //tf.textField.addEventListener(KeyboardEvent.KEY_DOWN, __onTextInputKeyDown);
        }
        return value;
    }

    /*
    private function __onTextInputKeyDown(e:KeyboardEvent) {
        if (_onKeyDown != null)
            _onKeyDown(e);
    }
    */

    private var _onKeyUp:KeyboardEvent->Void = null;
    public var onKeyUp(null, set):KeyboardEvent->Void;
    private function set_onKeyUp(value:KeyboardEvent->Void):KeyboardEvent->Void {
        if (_onKeyUp != null) {
            //tf.textField.removeEventListener(KeyboardEvent.KEY_UP, __onTextInputKeyUp);
        }
        _onKeyUp = value;
        if (_onKeyUp != null) {
            //tf.textField.addEventListener(KeyboardEvent.KEY_UP, __onTextInputKeyUp);
        }
        return value;
    }

    /*
    private function __onTextInputKeyUp(e:KeyboardEvent) {
        if (_onKeyUp != null)
            _onKeyUp(e);
    }
    */

    private function onInternalChange() {
        _text = tf.text;
        
        measureText();
        
        if (_inputData.onChangedCallback != null) {
            _inputData.onChangedCallback();
        }
    }
    
    private function onScroll() {
        _inputData.hscrollPos = tf.scrollH;
        _inputData.vscrollPos = tf.scrollV - 1;
        
        if (_inputData.onScrollCallback != null) {
            _inputData.onScrollCallback();
        }
    }

    public function update() {
    }

    public function addToComponent(component:Component) {
        //StateHelper.currentState.add(tf);
        component.add(tf);
    }

    public function destroy(component:Component) {
        tf.visible = false;
        component.remove(tf);
        tf.destroy();
        tf = null;
    }
}

#end