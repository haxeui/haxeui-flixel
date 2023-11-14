package haxe.ui.backend.flixel;

import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.backend.flixel.UIRTTITools.*;

using StringTools;

@:rtti
class UIRuntimeState extends UIStateBase { // uses rtti to "build" a class with a similar experience to using macros
	public var root:Component;

	public function new() {
		super();
	}

	public override function create() {
		var rtti = haxe.rtti.Rtti.getRtti(Type.getClass(this));
		root = buildViaRTTI(rtti);
		linkViaRTTI(rtti, this, root);
		if (root != null) {
			Screen.instance.addComponent(root);
		}
		super.create();
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

    public function dispatch<T:UIEvent>(event:T) {
		if (root == null) {
			throw "no root component";
		}

        root.dispatch(event);
    }

	public override function destroy() {
		if (root != null) {
			Screen.instance.removeComponent(root);
		}
		root = null;
	}
}