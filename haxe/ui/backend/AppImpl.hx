package haxe.ui.backend;

import flixel.FlxGame;
import haxe.ui.backend.flixel.FlxHaxeUIAppState;
import lime.graphics.Image;
import openfl.Lib;

class AppImpl extends AppBase {
    public function new() {
    }
    
    private override function build() {
        var targetFramerate = Toolkit.backendProperties.getPropInt("haxe.ui.flixel.fps", 60);

        #if (flixel < "5.0.0")
        Lib.current.stage.addChild(new FlxGame(0, 0, FlxHaxeUIAppState, 1, targetFramerate, targetFramerate, true));
        #else
        Lib.current.stage.addChild(new FlxGame(0, 0, FlxHaxeUIAppState, targetFramerate, targetFramerate, true));
        #end
        if (Toolkit.backendProperties.getPropBool("haxe.ui.flixel.fps.show")) {
            var x = Toolkit.backendProperties.getPropInt("haxe.ui.flixel.fps.left");
            var y = Toolkit.backendProperties.getPropInt("haxe.ui.flixel.fps.top");
            var c = Toolkit.backendProperties.getPropCol("haxe.ui.flixel.fps.color");
            Lib.current.stage.addChild(new openfl.display.FPS(x, y, c));
        }
    }

    private override function set_icon(value:String):String {
        if (_icon == value) {
            return value;
        }
        _icon = value;

        ToolkitAssets.instance.getImage(_icon, function(imageInfo) {
            if (imageInfo != null) {
                var iconImage = Image.fromBitmapData(imageInfo.data.parent.bitmap);
                Lib.current.stage.window.setIcon(iconImage);
            }
        });

        return value;
    }
}
