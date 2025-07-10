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
        var programPath = Sys.programPath();
        trace(programPath);
    }
}