package haxe.ui.backend;

import openfl.system.Capabilities;

class PlatformImpl extends PlatformBase {
    public override function getSystemLocale():String {
        return Capabilities.language;
    }
}