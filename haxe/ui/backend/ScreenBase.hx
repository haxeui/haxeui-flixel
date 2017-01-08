package haxe.ui.backend;

import flixel.group.FlxSpriteGroup;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.DialogButton;
import haxe.ui.core.Component;
import haxe.ui.core.UIEvent;

class ScreenBase {

    public function new() {

    }

    public var options:Dynamic;

    public var width(get, null):Float;
    public function get_width():Float {
        return container.width;
    }

    public var height(get, null):Float;
    public function get_height() {
        return container.width;
    }

    public var focus:Component;

    public var dpi(get, null):Float;
    public function get_dpi():Float {
        return 72.0;
    }

    private var _topLevelComponents:Array<Component> = new Array<Component>();
    public function addComponent(component:Component) {
        _topLevelComponents.push(component);
        container.add(component);
        component.ready();
    }

    public function removeComponent(component:Component) {
        _topLevelComponents.remove(component);
        container.remove(component, true);
    }

    private function handleSetComponentIndex(child:Component, index:Int) {
        container.group.insert(index, child);
    }

    private var container(default, null):FlxSpriteGroup;

    private function mapEvent(type:String, listener:UIEvent->Void) {

    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {

    }

    private function supportsEvent(type:String):Bool {
        return false;
    }

    public function messageDialog(message:String, title:String = null, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }

    public function showDialog(content:Component, options:Dynamic = null, callback:DialogButton->Void = null):Dialog {
        return null;
    }

    public function hideDialog(dialog:Dialog):Bool {
        return false;
    }
}