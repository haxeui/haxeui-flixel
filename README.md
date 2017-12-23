<p align="center">
  <img src="http://haxeui.org/db/haxeui2-warning.png"/>
</p>

# haxeui-flixel
`haxeui-flixel` is the `Flixel` backend for `HaxeUI`.


## Installation
`haxeui-flixel` relies on `haxeui-core` as well as `Flixel`. At the moment, `haxeui-flixel` is intended to be used with `dev` versions of `Flixel`. To install:

```
haxelib git flixel https://github.com/HaxeFlixel/flixel
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel
```

Also note that as of right now, `Flixel` has dependencies but can only run on `OpenFL 3.6.1` and `Lime 2.9.1`.

## Usage

After installing `Lime`, `OpenFL`, `Flixel`, `haxeui-core`, and `haxeUI-flixel`, the latter three should be included in `project.xml`. In the future, including `haxeui-flixel` will also handle the dependencies automatically.

```xml
<haxelib name="flixel" />
<haxelib name="haxeui-core" />
<haxelib name="haxeui-flixel" />
```

### Toolkit initialization and usage
Before you start using `HaxeUI` in your project, you must first initialize the `Toolkit`. In this backend, you must also specify a `FlxGroup` to act as the container for the UI and to connect `Flixel` and `HaxeUI`.

```haxe
var myContainer = new FlxGroup();
Toolkit.init( { container : myContainer } ); // you can also use "this" FlxState!
myContainer.memberAdded.add(FlxUIHelper.readyUI); // haxe.ui.backend.flixel.FlxUIHelper
add(myContainer);
```
Once the toolkit is initialized, you can add components using the methods specified <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">here</a>.

You can configure `haxeui-flixel` to use a spritesheet (`FlxAtlasFrames`) as a source for assets. The initialization becomes:
```haxe
var myContainer = new FlxGroup();
var myAtlas = FlxAtlasFrames.fromTexturePackerSource(...);
Toolkit.init( { container : myContainer, spritesheet : myAtlas } );
// etc
```
Then you can access the sprites within the spritesheet as if they were normal assets.

Alternatively, you can set up `HaxeUI` using `HaxeUIApp`. This defaults to using the current state as the `container`. The setup is the same for every `HaxeUI` backend:

```haxe
var app = new HaxeUIApp();
app.ready(
	function() {
		var main = ComponentMacros.buildComponent("assets/xml/test.xml");
		app.addComponent(main);
		app.start();
	}
);
```

Some examples are [here](https://github.com/haxeui/component-examples).

## Important Note
As of right now, there is a conflict within `haxeui-core` and `Flixel`. In order to compile, you must [comment out a line](https://github.com/haxeui/haxeui-core/blob/master/haxe/ui/core/Component.hx#L1168) in `haxeui-core`. This is already noted as an issue in the main repo: haxeui/haxeui-core#140.


## Addtional resources
* <a href="http://haxeui.github.io/haxeui-api/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
* <a href="https://github.com/haxeui/haxeui-demo">haxeui-demo</a> - Demo application written using HaxeUI.
* <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a> - Set of templates for IDE's to allow quick project creation.
* <a href="https://github.com/haxeui/haxeui-bdd">haxeui-bdd</a> - A behaviour driven development engine written specifically for HaxeUI (uses <a href="https://github.com/haxeui/haxe-bdd">haxe-bdd</a> which is a gherkin/cucumber inspired project).
* <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">WWX2016 presentation</a> - A presentation given at WWX2016 regarding HaxeUI.

