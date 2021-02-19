package haxe.ui.backend.flixel;

import flixel.FlxBasic;
import flixel.FlxCamera;
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
    
    public static function hasMember(member:FlxBasic, group:FlxTypedGroup<FlxBasic> = null):Bool {
        if (group == null) {
            group = currentState;
        }
        
        if (group == null || group.members == null) {
            return false;
        }
        
        if (member == group) {
            return true;
        }
        
        for (m in group.members) {
            if (m == member) {
                return true;
            }
            
            if ((m is FlxTypedGroup)) {
                if (hasMember(member, cast m) == true) {
                    return true;
                }
            } else if ((m is FlxSpriteGroup)) {
                if (groupHasMember(member, cast m) == true) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    private static function groupHasMember(member:FlxBasic, group:FlxSpriteGroup) {
        if (group == null || group.group == null || group.members == null) {
            return false;
        }
        
        if (member == group) {
            return true;
        }
        
        for (m in group.members) {
            if (m == member) {
                return true;
            }
            
            if ((m is FlxTypedGroup)) {
                if (hasMember(member, cast m) == true) {
                    return true;
                }
            } else if ((m is FlxSpriteGroup)) {
                if (groupHasMember(member, cast m) == true) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    public static function findCameras(member:FlxBasic, group:FlxTypedGroup<FlxBasic> = null):Array<FlxCamera> {
        if (group == null) {
            group = currentState;
        }
        
        if (group == null || group.members == null) {
            return null;
        }
        
        for (m in group.members) {
            if (m.cameras != null && m.cameras.length > 0) {
                if (m == member || ((m is FlxTypedGroup) && hasMember(member, cast m))) {
                    return m.cameras;
                }
            }
        }
        
        return null;
    }
}