package ;

import flash.Lib;
import flixel.FlxGame;
import flixel.FlxState;

/**
 * ...
 * @author MSGHero
 */
class GameClass extends FlxGame{

    var gameWidth:Int = 512; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
    var gameHeight:Int = 288; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
    var initialState:Class<FlxState> = TestState; // The FlxState the game starts with.
    var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
    var framerate:Int = 60; // How many frames per second the game should run at.
    var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
    var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

    public function new() {

        var stageWidth:Int = Lib.current.stage.stageWidth;
        var stageHeight:Int = Lib.current.stage.stageHeight;

        if (zoom == -1) {

            var ratioX:Float = stageWidth / gameWidth;
            var ratioY:Float = stageHeight / gameHeight;
            zoom = Math.min(ratioX, ratioY);
            gameWidth = Math.ceil(stageWidth / zoom);
            gameHeight = Math.ceil(stageHeight / zoom);
        }

        super(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
    }
}