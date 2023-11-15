package haxe.ui.backend.flixel;

import haxe.ui.RuntimeComponentBuilder;
import haxe.ui.core.Component;
import haxe.rtti.CType;
import haxe.ui.core.ComponentClassMap;

using StringTools;

class UIRTTITools {
	public static function buildViaRTTI(rtti:Classdef):Component {
        var root:Component = null;
		var m = getMetaWithValueRTTI(rtti.meta, "build", "haxe.ui.RuntimeComponentBuilder.build");
		if (m != null) {
			var assetId = m.params[0].replace("haxe.ui.RuntimeComponentBuilder.build(", "").replace(")", "");
			assetId = assetId.replace("\"", "");
			assetId = assetId.replace("'", "");
			root = RuntimeComponentBuilder.fromAsset(assetId);
			if (root == null) {
				throw "could not loading runtime ui from asset (" + assetId + ")";
			}
		}
		m = getMetaRTTI(rtti.meta, "xml");
		if (m != null) { // comes back as an escaped CDATA section
			var xmlString = m.params[0].trim();
			if (xmlString.startsWith("<![CDATA[")) {
				xmlString = xmlString.substring("<![CDATA[".length);
			}
			if (xmlString.endsWith("]]>")) {
				xmlString = xmlString.substring(0, xmlString.length - "]]>".length);
			}
			if (xmlString.startsWith("\"")) {
				xmlString = xmlString.substring(1);
			}
			if (xmlString.endsWith("\"")) {
				xmlString = xmlString.substring(0, xmlString.length - 1);
			}
			xmlString = xmlString.replace("\\r", "\r");
			xmlString = xmlString.replace("\\n", "\n");
			xmlString = xmlString.replace("\\\"", "\"");
			xmlString = xmlString.trim();
            try {
			    root = RuntimeComponentBuilder.fromString(xmlString);
            } catch (e:Dynamic) {
                trace("ERROR", e);
            }
		}
        return root;
	}

    public static function linkViaRTTI(rtti:Classdef, target:Dynamic, root:Component, force:Bool = false) {
		if (root == null) {
			return;
		}
		for (f in rtti.fields) {
			switch (f.type) {
				case CClass(name, params):
					if (ComponentClassMap.instance.hasClassName(name)) {
						var candidate = root.findComponent(f.name);
						if (force) {
							Reflect.setField(target, f.name, null);
						}
						if (candidate != null && Reflect.field(target, f.name) == null) {
                            var temp = Type.createEmptyInstance(Type.resolveClass(name));
                            if ((temp is IComponentDelegate)) {
                                var componentDelegate:IComponentDelegate = Type.createEmptyInstance(Type.resolveClass(name));
                                componentDelegate.component = candidate;
                                Reflect.setField(target, f.name, componentDelegate);
                            } else {
                                Reflect.setField(target, f.name, candidate);
                            }
						}
					}
				case CFunction(args, ret):
					var m = getMetaRTTI(f.meta, "bind");
					if (m != null) {
                        if (m.params[0] == "this") {
                            if ((target is IComponentDelegate)) {
                                var componentDelegate:IComponentDelegate = cast target;
                                bindEvent(rtti, componentDelegate.component, f.name, target, m.params[1], true);
                            } else {
                                bindEvent(rtti, root, f.name, target, m.params[1]);
                            }
                        } else {
                            var candidate:Component = root.findComponent(m.params[0]);
                            if (candidate != null) {
                                bindEvent(rtti, candidate, f.name, target, m.params[1]);
                            } else {
                                // another perfectly valid contruct, albeit less common (though still useful), is the ability to use 
                                // @:bind to bind to variables on static fields, eg:
                                //     @:bind(MyClass.instance, SomeEvent.EventType)
                                // this code facilitates that by attempting to resolve the item and binding the event to it
                                var parts = m.params[0].split(".");
                                var className = parts.shift();
                                var c = Type.resolveClass(className);

                                if (c == null) {
                                    // this allows full qualified class names:
                                    //    @:bind(some.pkg.MyClass.instance, SomeEvent.EventType)
                                    // by looping over each part looking for a valid class
                                    // its not fast (or pretty), but it will only happen once (per @:bind)
                                    var candidateClass = className;
                                    while (parts.length > 0) {
                                        var part = parts.shift();
                                        candidateClass += "." + part;
                                        var temp = Type.resolveClass(candidateClass);
                                        if (temp != null) {
                                            c = temp;
                                            break;
                                        }
                                    }
                                }

                                if (c != null) {
                                    var ref:Dynamic = c;
                                    var found = (parts.length > 0);
                                    for (part in parts) {
                                        if (!Reflect.hasField(ref, part)) {
                                            found = false;
                                            break;
                                        }
                                        ref = Reflect.field(ref, part);
                                    }
                                    if (found) {
                                        if (ref != null) {
                                            if ((ref is UIRuntimeState)) {
                                                var state:UIRuntimeState = cast ref;
                                                bindEvent(rtti, state.root, f.name, target, m.params[1]);
                                            } else if ((ref is UIRuntimeSubState)) {
                                                var subState:UIRuntimeSubState = cast ref;
                                                bindEvent(rtti, subState.root, f.name, target, m.params[1]);
                                            } else if ((ref is IComponentDelegate)) {
                                                var componentDelegate:IComponentDelegate = cast ref;
                                                bindEvent(rtti, componentDelegate.component, f.name, target, m.params[1]);
                                            } else if ((ref is Component)) {
                                                var component:Component = cast ref;
                                                bindEvent(rtti, component, f.name, target, m.params[1]);
                                            }
                                        } else {
                                            throw "bind param resolved, but was null '" + m.params[0] + "'";
                                        }
                                    } else {
                                        throw "could not resolve bind param '" + m.params[0] + "'";
                                    }
                                } else {
                                    throw "could not resolve class '" + className + "'";
                                }
                            }
                        }
					}
				case _:			
			}
		}
    }

    private static function bindEvent(rtti:Classdef, candidate:Component, fieldName:String, target:Dynamic, eventClass:String, isComponentDelegate:Bool = false) {
        if (candidate == null) {
            return;
        }
        var parts = eventClass.split(".");
        var eventName = parts.pop();
        eventClass = parts.join(".");
        var c = resolveEventClass(rtti, eventClass);
        if (c != null) {
            var eventString = Reflect.field(c, eventName);
            var fn = Reflect.field(target, fieldName);
            // this may be ill-concieved, but if we are talking about a component delegate (ie, a fragment)
            // it means we are going to attach a component to an "empty" class which means this code has
            // already run once, meaning there are two event listeners, this way we remove them first
            // in practice its probably _exactly_ what we want, but this could also clear up binding
            // two functions to the same event (which isnt common at all)
            if (isComponentDelegate) {
                candidate.unregisterEvents(eventString);
            }
            candidate.registerEvent(eventString, fn);
        } else {
            throw "could not resolve event class '" + eventClass + "' (you may need to use fully qualified class names)";
        }
    }

    private static function resolveEventClass(rtti:Classdef, eventClass:String) {
        var candidateEvent = "haxe.ui.events." + eventClass;
        var event = Type.resolveClass(candidateEvent);
        if (event != null) {
            return event;
        }

        var event = Type.resolveClass(eventClass);
        if (event != null) {
            return event;
        }

        // this is pretty brute force method, were going to see if we can find any functions
        // with @:bind meta, these are presumably the event handlers, if we can find one
        // where the the last part of the arg type (which would be the event type) matches
        // the event we are looking for, we'll consider that match, and can use that as a
        // fully qualified event class
        for (f in rtti.fields) {
            switch (f.type) {
                case CFunction(args, ret):
                    if (getMetaRTTI(f.meta, "bind") != null) {
                        for (arg in args) {
                            switch (arg.t) {
                                case CClass(name, params):
                                    if (name.endsWith(eventClass)) {
                                        var event = Type.resolveClass(name);
                                        if (event != null) {
                                            return event;
                                        }
                                    }
                                case _:    
                            }
                        }
                    }
                case _:    
            }
        }

        return null;
    }

	private static function getMetaRTTI(metadata:MetaData, name:String):{name:String, params:Array<String>} {
		for (m in metadata) {
			if (m.name == name || m.name == ":" + name) {
				return m;
			}
		}
		return null;
	}

	private static function getMetasRTTI(metadata:MetaData, name:String):Array<{name:String, params:Array<String>}> {
		var metas = [];
		for (m in metadata) {
			if (m.name == name || m.name == ":" + name) {
				metas.push(m);
			}
		}
		return metas;
	}

	private static function getMetaWithValueRTTI(metadata:MetaData, name:String, value:String, paramIndex:Int = 0):{name:String, params:Array<String>} {
		for (m in metadata) {
			if (m.name == name || m.name == ":" + name) {
				if (m.params[paramIndex].startsWith(value)) {
					return m;
				}
			}
		}
		return null;
	}
}