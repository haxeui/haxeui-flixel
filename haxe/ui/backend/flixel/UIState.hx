package haxe.ui.backend.flixel;

import haxe.ui.layouts.LayoutFactory;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;

@:autoBuild(haxe.ui.macros.Macros.buildBehaviours())
@:autoBuild(haxe.ui.macros.Macros.build())
class UIState extends UIStateBase { // must use -D haxeui_dont_impose_base_class
    public var bindingRoot:Bool = false;

    private var root:Box = new Box(); // root component is always a box for now, since there is no nice / easy way to get the root node info from the macro

    public function new() {
        super();
    }

    private function applyRootLayout(l:String) {
        if (l == "vbox") {
            root.layout = LayoutFactory.createFromName("vertical");
        } else if (l == "hbox") {
            root.layout = LayoutFactory.createFromName("horizontal");
        }
    }

    public override function create() {
        super.create();

        add(root);
    }

    private function onReady() {
    }

    public function validateNow() {
        root.validateNow();
    }

    private function registerBehaviours() {
    }

    public function addComponent(child:Component):Component  {
        return root.addComponent(child);
    }

    public var width(get, set):Float;
    private function get_width():Float {
        return root.width;
    }
    private function set_width(value:Float):Float {
        root.width = value;
        return value;
    }

    public var percentWidth(get, set):Float;
    private function get_percentWidth():Float {
        return root.percentWidth;
    }
    private function set_percentWidth(value:Float):Float {
        root.percentWidth = value;
        return value;
    }

    public var height(get, set):Float;
    private function get_height():Float {
        return root.height ;
    }
    private function set_height(value:Float):Float {
        root.height  = value;
        return value;
    }

    public var percentHeight(get, set):Float;
    private function get_percentHeight():Float {
        return root.percentHeight ;
    }
    private function set_percentHeight(value:Float):Float {
        root.percentHeight  = value;
        return value;
    }

    public var styleString(get, set):String;
    private function get_styleString():String {
        return root.styleString ;
    }
    private function set_styleString(value:String):String {
        root.styleString  = value;
        return value;
    }

	public function show() {
		root.show();
	}

	public function hide() {
		root.hide();
	}
}