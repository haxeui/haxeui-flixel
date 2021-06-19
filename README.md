![build status](https://github.com/haxeui/haxeui-flixel/actions/workflows/build.yml/badge.svg)

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
Before you start using `HaxeUI` in your project, you must first initialize the `Toolkit`.

```haxe
Toolkit.init();
```

Once the toolkit is initialized, you can add components using the methods specified <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">here</a>.

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
