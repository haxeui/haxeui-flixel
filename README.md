<p align="center">
  <img src="http://haxeui.org/db/haxeui2-warning.png"/>
</p>

# haxeui-flixel
`haxeui-flixel` is the `Flixel` backend for HaxeUI.


## Installation
`haxeui-flixel` relies on `haxeui-core` as well as `flixel`. At the moment, `haxeui-flixel` is intended to be used with `dev` versions of flixel. To install:

```
haxelib git flixel https://github.com/HaxeFlixel/flixel
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib git haxeui-flixel https://github.com/haxeui/haxeui-flixel
```

Also note that as of right now, `flixel` has dependencies but can only run on `OpenFL 3.6.1` and `Lime 2.9.1`.

## Usage

After installing `Lime`, `OpenFL`, `Flixel`, `HaxeUI-core`, and `HaxeUI-flixel`, the latter three should be included in `project.xml`. In the future, including `haxeui-flixel` will also handle the dependencies automatically.

```xml
<haxelib name="flixel" />
<haxelib name="haxeui-core" />
<haxelib name="haxeui-flixel" />
```

### Toolkit initialization and usage
Before you start using HaxeUI in your project, you must first initialize the `Toolkit`. In this backend, you must also specify a `FlxGroup` to act as the container for the UI.

```haxe
var myContainer = new FlxGroup();
Toolkit.init( { container : myContainer } ); // you can also pass in "this" FlxState!
```
Once the toolkit is initialized, you can add components using the methods specified <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">here</a>.

You can configure HaxeUI to use a spritesheet (`FlxAtlasFrames`) as a source for assets. The initialization becomes:
```haxe
var myContainer = new FlxGroup();
var myAtlas = FlxAtlasFrames.fromTexturePackerSource(...);
Toolkit.init( { container : myContainer, spriteSheet : myAtlas } );
```
Then you can access a sprite within the spritesheet by name from the XML configuration.

## Important Note
As of right now, there is a conflict within `haxeui-core` and `flixel`. In order to compile, you must [comment out a line](https://github.com/haxeui/haxeui-core/blob/master/haxe/ui/core/Component.hx#L1168) in `haxeui-core`. This is already noted as an issue in the main repo: haxeui/haxeui-core#140.


## Addtional resources
* <a href="http://haxeui.github.io/haxeui-api/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
* <a href="https://github.com/haxeui/haxeui-demo">haxeui-demo</a> - Demo application written using HaxeUI.
* <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a> - Set of templates for IDE's to allow quick project creation.
* <a href="https://github.com/haxeui/haxeui-bdd">haxeui-bdd</a> - A behaviour driven development engine written specifically for HaxeUI (uses <a href="https://github.com/haxeui/haxe-bdd">haxe-bdd</a> which is a gherkin/cucumber inspired project).
* <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">WWX2016 presentation</a> - A presentation given at WWX2016 regarding HaxeUI.

