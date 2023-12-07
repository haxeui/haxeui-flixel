package haxe.ui.backend;

typedef TextInputEvent = {type:String, stageX:Float, stageY:Float};

#if flixel_text_input

typedef TextInputImpl = haxe.ui.backend.flixel.textinputs.FlxTextInput;

#else

typedef TextInputImpl = haxe.ui.backend.flixel.textinputs.OpenFLTextInput;

#end
