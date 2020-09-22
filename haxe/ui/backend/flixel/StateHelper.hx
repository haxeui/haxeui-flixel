package haxe.ui.backend.flixel;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;

class StateHelper {
    public static var currentState(get, null):FlxState;
    private static function get_currentState():FlxState {
        var s:FlxState = FlxG.state;
        if (s != null && s.subState != null) {
            var r = s.subState;
            while (r != null) {
                if (r.subState == null) {
                    break;
                }
                r = r.subState;
            }
            s = r;
        }
        return s;
    }
    
    public static function stateHasMember(member:FlxBasic, state:FlxState = null):Bool {
        if (state == null) {
            state = currentState;
        }
        
        for (m in state.members) {
            if (m == member) {
                return true;
            }
            
            if (Std.is(m, FlxSpriteGroup)) {
                if (groupHasMember(member, cast m) == true) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    private static function groupHasMember(member:FlxBasic, group:FlxSpriteGroup):Bool {
        for (m in group.members) {
            if (m == member) {
                return true;
            }
            
            if (Std.is(m, FlxSpriteGroup)) {
                if (groupHasMember(member, cast m) == true) {
                    return true;
                }
            }
        }
        return false;
    }
}