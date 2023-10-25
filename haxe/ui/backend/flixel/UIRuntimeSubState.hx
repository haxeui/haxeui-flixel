package haxe.ui.backend.flixel;

import haxe.rtti.CType;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.Screen;
import haxe.ui.RuntimeComponentBuilder;
import haxe.ui.core.Component;

using StringTools;

@:rtti
class UIRuntimeSubState extends UISubStateBase { // uses rtti to "build" a class with a similar experience to using macros
	public var root:Component;

	public var assetId:String;

	public function new(assetId:String = null) {
		super();
		this.assetId = assetId;
		buildViaRTTI();
		linkViaRTTI();
	}

	public override function create() {
		super.create();
		if (root != null) {
			Screen.instance.addComponent(root);
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////
	// util functions
	/////////////////////////////////////////////////////////////////////////////////////////////////
	public function addComponent(child:Component):Component {
		if (root == null) {
			throw "no root component";
		}

		return root.addComponent(child);
	}

	public function removeComponent(child:Component):Component {
		if (root == null) {
			throw "no root component";
		}

		return root.removeComponent(child);
	}

	public function findComponent<T:Component>(criteria:String = null, type:Class<T> = null, recursive:Null<Bool> = null, searchType:String = "id"):Null<T> {
		if (root == null) {
			throw "no root component";
		}

		return root.findComponent(criteria, type, recursive, searchType);
	}

	public function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
		if (root == null) {
			throw "no root component";
		}

		return root.findComponents(styleName, type, maxDepth);
	}

	public function findAncestor<T:Component>(criteria:String = null, type:Class<T> = null, searchType:String = "id"):Null<T> {
		if (root == null) {
			throw "no root component";
		}

		return root.findAncestor(criteria, type, searchType);
	}

	public function findComponentsUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Array<Component> {
		if (root == null) {
			throw "no root component";
		}

		return root.findComponentsUnderPoint(screenX, screenY, type);
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////
	// rtti functions
	/////////////////////////////////////////////////////////////////////////////////////////////////
	private function buildViaRTTI() {
		var rtti = haxe.rtti.Rtti.getRtti(Type.getClass(this));
		var m = getMetaWithValueRTTI(rtti.meta, "build", "haxe.ui.RuntimeComponentBuilder.build");
		if (m != null) {
			assetId = m.params[0].replace("haxe.ui.RuntimeComponentBuilder.build(", "").replace(")", "");
			assetId = assetId.replace("\"", "");
			assetId = assetId.replace("'", "");
			this.root = RuntimeComponentBuilder.fromAsset(assetId);
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
			    this.root = RuntimeComponentBuilder.fromString(xmlString);
            } catch (e:Dynamic) {
                trace("ERROR", e);
            }
		}
	}

	private function linkViaRTTI(force:Bool = false) {
		if (root == null) {
			return;
		}
		var rtti = haxe.rtti.Rtti.getRtti(Type.getClass(this));
		for (f in rtti.fields) {
			switch (f.type) {
				case CClass(name, params):
					if (ComponentClassMap.instance.hasClassName(name)) {
						var candidate = root.findComponent(f.name);
						if (force) {
							Reflect.setField(this, f.name, null);
						}
						if (candidate != null && Reflect.field(this, f.name) == null) {
							Reflect.setField(this, f.name, candidate);
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
								var fn = Reflect.field(this, f.name);
								candidate.registerEvent(eventString, fn);
							}

						}
					}
				case _:			
			}
		}
	}

	private function getMetaRTTI(metadata:MetaData, name:String):{name:String, params:Array<String>} {
		for (m in metadata) {
			if (m.name == name || m.name == ":" + name) {
				return m;
			}
		}
		return null;
	}

	private function getMetasRTTI(metadata:MetaData, name:String):Array<{name:String, params:Array<String>}> {
		var metas = [];
		for (m in metadata) {
			if (m.name == name || m.name == ":" + name) {
				metas.push(m);
			}
		}
		return metas;
	}

	private function getMetaWithValueRTTI(metadata:MetaData, name:String, value:String, paramIndex:Int = 0):{name:String, params:Array<String>} {
		for (m in metadata) {
			if (m.name == name || m.name == ":" + name) {
				if (m.params[paramIndex].startsWith(value)) {
					return m;
				}
			}
		}
		return null;
	}

	public override function destroy() {
		if (root != null) {
			remove(root);
		}
		root = null;
	}
}