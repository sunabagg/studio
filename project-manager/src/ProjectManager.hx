package;

import sunaba.ui.Widget;
import sunaba.desktop.AcceptDialog;
import sunaba.core.Vector2i;
import sunaba.core.Vector2;
import sunaba.core.Rect2i;
import sunaba.desktop.PopupMenu;
import sunaba.desktop.FileDialog;
import sunaba.core.ArrayList;
import sunaba.core.Variant;
import sunaba.FileDialogMode;
import sunaba.core.SubViewport;
import sunaba.Runtime;
import sunaba.App;
import sunaba.core.PlatformService;
import sunaba.core.DeviceType;
import sunaba.input.InputEvent;
import sunaba.input.InputService;
import sunaba.Key;
import sunaba.ui.Control;
import sunaba.WindowMode;
import sunaba.core.Element;
import sunaba.desktop.Window;
import sunaba.ui.Button;
import sys.FileSystem;
import lua.Table;

class ProjectManager extends Widget {
    override function init() {
        load("app://ProjectManager.suml");

        var openProjectButton = Button.toButton(rootElement.find("vbox/toolbar/hbox/openProjectButton"));
        openProjectButton.pressed.connect((args: ArrayList) -> {
            var openProjectDialog = new FileDialog();
            openProjectDialog.fileMode = FileDialogMode.openFile;
            openProjectDialog.useNativeDialog = true;
            openProjectDialog.access = 2;
            openProjectDialog.title = "Open Project";
            openProjectDialog.addFilter("*.snbproj", "Sunaba Project");
            rootElement.addChild(openProjectDialog);

            openProjectDialog.fileSelected.connect((args: ArrayList) -> {
                var path = args.get(0).toString();
                openProjectDialog.hide();
                openProjectDialog.delete();
                openProject(path);
            });

            openProjectDialog.popupCentered(new Vector2i(0, 0));

        });
    }

    function openProject(path: String) {
        var editorBinPath = App.execDir + "/editor.sbx";
        if (PlatformService.hasFeature("editor")) {
            editorBinPath = App.resDir + "/editor.sbx";
        }
        else if (FileSystem.exists(App.shareDir + "/editor.sbx")) {
            editorBinPath = App.shareDir + "/editor.sbx";
        }

        var window = new Window();
        rootElement.addChild(window);
        window.hide();
        window.title = "Sunaba Studio";
        window.size = rootElement.getWindow().size;
        window.closeRequested.connect((args: ArrayList) -> {
             window.delete();
        });

        var runtime = new Runtime();
        var args = runtime.args;
        args.add(path);
        runtime.args = args;
        runtime.init(false);
        window.addChild(runtime);
        runtime.load(editorBinPath);

        window.popupCentered(rootElement.getWindow().size);
    }
}