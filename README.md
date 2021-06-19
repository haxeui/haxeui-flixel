# haxeui-flixel
`haxeui-flixel` is the `Flixel` backend for `HaxeUI`.


## Installation
`haxeui-flixel` relies on `haxeui-core` as well as `Flixel`. To install:

```
haxelib install flixel
haxelib install haxeui-core
haxelib install haxeui-flixel
```

## Usage

After installing `Lime`, `OpenFL`, `Flixel`, `haxeui-core`, and `haxeui-flixel`, the latter three should be included in `project.xml`. In the future, including `haxeui-flixel` will also handle the dependencies automatically.

```xml
<haxelib name="flixel" />
<haxelib name="haxeui-core" />
<haxelib name="haxeui-flixel" />
```

### Toolkit initialization and usage
Before you start using `HaxeUI` in your project, you must first initialize the `Toolkit`. You can specify a `FlxGroup` to act as the container for the UI.

```haxe
var myContainer = new FlxGroup();
Toolkit.init( { container : myContainer } );
add(myContainer);
```

You can also do:
```haxe
Toolkit.init( { } ); // defaults to FlxG.state
Toolkit.init( { container : this } ); // "this" FlxState, or whatever else "this" is referring to (has to extend FlxGroup)
Toolkit.init( { container : myFlxSpriteGroup.group } ); // FlxSpriteGroup as the container
```

Once the toolkit is initialized, you can add components using the methods specified <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">here</a>.

You can configure `haxeui-flixel` to use a spritesheet (`FlxAtlasFrames`) as a source for assets. The initialization becomes:
```haxe
var myContainer = new FlxGroup();
var myAtlas = FlxAtlasFrames.fromTexturePackerSource(...);
Toolkit.init( { container : myContainer, spritesheet : myAtlas } );
// etc
```
Then you can access the sprites within the spritesheet as if they were normal assets. For instance, a sprite named "mySprite" in your spritesheet can be accessed like `<button icon="mySprite" />` in your `HaxeUI` XML layout.

Alternatively, you can set up `HaxeUI` using `HaxeUIApp`. This defaults to using the current state as the `container`. The setup is the same for every `HaxeUI` backend:

```haxe
var app = new HaxeUIApp();
app.ready(
	function() {
		var main = ComponentMacros.buildComponent("assets/xml/test.xml"); // whatever your XML layout path is
		app.addComponent(main);
		app.start();
	}
);
```

Some examples are [here](https://github.com/haxeui/component-examples).

## Addtional resources
* <a href="http://haxeui.org/explorer/">component-explorer</a> - Browse HaxeUI components
* <a href="http://haxeui.org/builder/">playground</a> - Write and test HaxeUI layouts in your browser
* <a href="https://github.com/haxeui/component-examples">component-examples</a> - Various componet examples
* <a href="http://haxeui.org/api/haxe/ui/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
