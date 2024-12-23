package haxe.ui.backend;

typedef TextInputEvent = {type:String, stageX:Float, stageY:Float};

#if (flixel >= "5.9.0")
typedef TextInputImpl = haxe.ui.backend.flixel.textinputs.FlxTextInput;
#else
typedef TextInputImpl = haxe.ui.backend.flixel.textinputs.OpenFLTextInput;
#end
