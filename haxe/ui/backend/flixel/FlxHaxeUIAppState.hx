package haxe.ui.backend.flixel;

import flixel.FlxG;
import flixel.FlxState;

class FlxHaxeUIAppState extends FlxState {
    public override function create() {
        if (Toolkit.backendProperties.getProp("haxe.ui.flixel.scaleMode") == "stage") {
            FlxG.scaleMode = new flixel.system.scaleModes.StageSizeScaleMode();  
        }

        if (Toolkit.backendProperties.exists("haxe.ui.flixel.mouse.useSystemCursor")) {
            #if !FLX_NO_MOUSE
            FlxG.mouse.useSystemCursor = Toolkit.backendProperties.getPropBool("haxe.ui.flixel.mouse.useSystemCursor");
            #end
        }
        
        super.create();
        
        if (Toolkit.backendProperties.exists("haxe.ui.flixel.background.color")) {
            this.bgColor = Toolkit.backendProperties.getPropCol("haxe.ui.flixel.background.color") | 0xFF000000;
        }
    }
}
