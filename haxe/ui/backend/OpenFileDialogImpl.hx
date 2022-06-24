package haxe.ui.backend;

import haxe.ui.containers.dialogs.Dialogs.SelectedFileInfo;
#if !js
import haxe.io.Bytes;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.net.FileReferenceList;
#end

using StringTools;

class OpenFileDialogImpl extends OpenFileDialogBase {
    #if js
    
    private var _fileSelector:haxe.ui.util.html5.FileSelector = new haxe.ui.util.html5.FileSelector();
    
    public override function show() {
        var readMode = haxe.ui.util.html5.FileSelector.ReadMode.None;
        if (options.readContents == true) {
            if (options.readAsBinary == false) {
                readMode = haxe.ui.util.html5.FileSelector.ReadMode.Text;
            } else {
                readMode = haxe.ui.util.html5.FileSelector.ReadMode.Binary;
            }
        }
        _fileSelector.selectFile(onFileSelected, readMode, options.multiple, options.extensions);
    }
    
    private function onFileSelected(cancelled:Bool, files:Array<SelectedFileInfo>) {
        if (cancelled == false) {
            dialogConfirmed(files);
        } else {
            dialogCancelled();
        }
    }
    
    #else
    
    private var _fr:FileReferenceList = null;
    private var _refToInfo:Map<FileReference, SelectedFileInfo>;
    private var _infos:Array<SelectedFileInfo>;
    
    public override function show() {
        _refToInfo = new Map<FileReference, SelectedFileInfo>();
        _infos = [];
        _fr = new FileReferenceList();
        _fr.addEventListener(Event.SELECT, onSelect, false, 0, true);
        _fr.addEventListener(Event.CANCEL, onCancel, false, 0, true);
        _fr.browse(buildFileFilters());
    }
    
    private function buildFileFilters():Array<FileFilter> {
        var f = null;
        
        /* DOESNT WORK AS OPENFL DOCS STATE
        if (options.extensions != null && options.extensions.length > 0) {
            f = [];
            for (e in options.extensions) {
                var ext = e.extension;
                ext = ext.trim();
                if (ext.length == 0) {
                    continue;
                }
                var parts = ext.split(",");
                var finalParts = [];
                for (p in parts) {
                    p = p.trim();
                    if (p.length == 0) {
                        continue;
                    }
                    finalParts.push("*." + p);
                }
                
                f.push(new FileFilter(e.label, finalParts.join(";")));
            }
        }
        */
        
        return f;
    }
    
    private function onSelect(e:Event) {
        var fileList:Array<FileReference> = _fr.fileList;
        destroyFileRef();
        var infos:Array<SelectedFileInfo> = [];
        for (fileRef in fileList) {
            var info:SelectedFileInfo = {
                isBinary: false,
                name: fileRef.name
            }
            if (options.readContents == true) {
                _refToInfo.set(fileRef, info);
            }
            infos.push(info);
        }
        
        if (options.readContents == false) {
            dialogConfirmed(infos);
        } else {
            for (fileRef in _refToInfo.keys()) {
                fileRef.addEventListener(Event.COMPLETE, onFileComplete, false, 0, true);
                fileRef.load();
            }
        }
        
    }
    
    private function onFileComplete(e:Event) {
        var fileRef = cast(e.target, FileReference);
        fileRef.removeEventListener(Event.COMPLETE, onFileComplete);
        var info = _refToInfo.get(fileRef);
        if (options.readAsBinary == true) {
            info.isBinary = true;
            info.bytes = Bytes.ofData(fileRef.data);
        } else {
            info.isBinary = false;
            info.text = fileRef.data.toString();
        }
        
        _infos.push(info);
        _refToInfo.remove(fileRef);
        if (isMapEmpty()) {
            var copy = _infos.copy();
            _infos = null;
            _refToInfo = null;
            dialogConfirmed(copy);
        }
    }

    private function isMapEmpty() {
        if (_refToInfo == null) {
            return true;
        }
        
        var n = 0;
        for (_ in _refToInfo.keys()) {
            n++;
        }
        
        return (n == 0);
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