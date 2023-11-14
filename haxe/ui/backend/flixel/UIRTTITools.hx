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
						var candidate:Component = root.findComponent(m.params[0]);
						if (candidate != null) {
							var parts = m.params[1].split(".");
							var candidateEvent = "haxe.ui.events." + parts[0];
							var c = Type.resolveClass(candidateEvent);
							if (c != null) {
								var eventString = Reflect.field(c, parts[1]);
								var fn = Reflect.field(target, f.name);
								candidate.registerEvent(eventString, fn);
							}

						}
					}
				case _:			
			}
		}
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