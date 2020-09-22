package haxe.ui.backend.flixel;

import flixel.FlxG;
import flixel.FlxState;

class FlxHaxeUIAppState extends FlxState {
    public override function create() {
        if (Toolkit.backendProperties.exists("haxe.ui.flixel.mouse.useSystemCursor")) {
            FlxG.mouse.useSystemCursor = Toolkit.backendProperties.getPropBool("haxe.ui.flixel.mouse.useSystemCursor");
        }
        
        super.create();
        
        this.bgColor = Toolkit.backendProperties.getPropCol("haxe.ui.flixel.background.color") | 0xFF000000;
    }
}
