package haxe.ui.backend.flixel.macros;

#if macro
import haxe.macro.Expr.Field;
import haxe.macro.Context;

/**
 * Macro which makes an error at compile time if the user attemps to use `UIState` or `UISubState` without having `haxeui_dont_impose_base_class` defined.
 */
class UIStateMacro {
    public static function checkDefine():Array<Field> {
        var localClass:String = Context.getLocalClass().get().name;

        if (!Context.defined("haxeui_dont_impose_base_class"))
            Context.error("You must define haxeui_dont_impose_base_class in order to use " + findUIClass() + " (for class " + localClass + ")", Context.currentPos());

        return Context.getBuildFields();
    }

    static function findUIClass():String {
        var cls = Context.getLocalClass().get();

        while (!isUIState(cls.name)) {
            if (cls.superClass == null)
                break;

            cls = cls.superClass.t.get();
        }

        if (!isUIState(cls.name)) {
            // shouldn't happen, but just in case
            return "UI states";
        }

        return cls.name;
    }

    static function isUIState(name:String):Bool {
        return name == "UIState" || name == "UISubState";
    }
}
#end
