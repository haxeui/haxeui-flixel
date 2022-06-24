package haxe.ui.backend;

#if !js
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
#end

class SaveFileDialogImpl extends SaveFileDialogBase {
    #if js
    
    private var _fileSaver:haxe.ui.util.html5.FileSaver = new haxe.ui.util.html5.FileSaver();
    
    public override function show() {
        if (fileInfo == null || (fileInfo.text == null && fileInfo.bytes == null)) {
            throw "Nothing to write";
        }
        
        if (fileInfo.text != null) {
            _fileSaver.saveText(fileInfo.name, fileInfo.text, onSaveResult);
        } else if (fileInfo.bytes != null) {
            _fileSaver.saveBinary(fileInfo.name, fileInfo.bytes, onSaveResult);
        }
    }
    
    private function onSaveResult(r:Bool) {
        if (r == true) {
            dialogConfirmed();
        } else {
            dialogCancelled();
        }
    }
    
    #else
    
    private var _fr:FileReference = null;
    
    public override function show() {
        if (fileInfo == null || (fileInfo.text == null && fileInfo.bytes == null)) {
            throw "Nothing to write";
        }
        
        var data:Dynamic = fileInfo.text;
        if (data == null) {
            data = ByteArray.fromBytes(fileInfo.bytes);
        }
        _fr = new FileReference();
        _fr.addEventListener(Event.SELECT, onSelect, false, 0, true);
        _fr.addEventListener(Event.CANCEL, onCancel, false, 0, true);
        _fr.save(data, fileInfo.name);
    }
    
    private function onSelect(e:Event) {
        destroyFileRef();
        dialogConfirmed();
    }
    
    private function onCancel(e:Event) {
        destroyFileRef();
        dialogCancelled();
    }

    private function destroyFileRef() {
        if (_fr == null) {
            return;
        }
        
        _fr.removeEventListener(Event.SELECT, onSelect);
        _fr.removeEventListener(Event.CANCEL, onCancel);
        _fr = null;
    }
    
    #end
}
