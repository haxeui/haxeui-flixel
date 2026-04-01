![build status](https://github.com/haxeui/haxeui-flixel/actions/workflows/build.yml/badge.svg)

# haxeui-flixel
`haxeui-flixel`, `HaxeUI`'ın `Flixel` arkaucudur.

## Kurulum
`haxeui-flixel`, `Flixel`'e olduğu kadar da `haxeui-core`'a da dayanır. Kurmak için:
```
haxelib install flixel
haxelib install haxeui-core
haxelib install haxeui-flixel
```
kullanın.

## Kullanım

`Lime`, `OpenFL`, `Flixel`, `haxeui-core`, ve `haxeui-flixel`'ı kurduktan sonra, son üçü de `project.xml`'de bulunmalıdır. Gelecekte `haxeui-flixel`'ı eklemek, ayrıca bağımlılıkları elden geçirecektir.

```xml
<haxelib name="flixel" />
<haxelib name="haxeui-core" />
<haxelib name="haxeui-flixel" />
```

### Araç takımı dahil etme ve kullanım
`HaxeUI`'ı kullanmaya başlamadan önce, `Toolkit`'i dahil etmelisiniz.

```haxe
Toolkit.init();
```

Araç takımını dahil edince <a href="https://github.com/haxeui/haxeui-core#adding-components-using-haxe-code">burada</a> tarif edilen yöntemler ile komponentleri ekleyebilirsiniz.

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

Bazı örnekleri [burada](https://github.com/haxeui/component-examples) yer almaktadır.
## Ek Kaynaklar
* <a href="http://haxeui.org/explorer/">component-explorer</a> - HaxeUI komponentlerinde gezinin
* <a href="http://haxeui.org/builder/">playground</a> - Tarayıcınızda HaxeUI görünümlerini yazıp test edin
* <a href="https://github.com/haxeui/component-examples">component-examples</a> - Bir takım komponent örnekleri
* <a href="http://haxeui.org/api/haxe/ui/">haxeui-api</a> - HaxeUI api dökümanları
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - HaxeUI ve arkauçlarıyla çalışmak için birtakım rehberler.

