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
import editor.ProjectTree;

class Editor extends Widget {
    var snbProjPath: String = "";

    var projectTree: ProjectTree;

    override function init() {
        load("app://Editor.suml");

        var menuBarControl: Control = Control.toControl(rootElement.find(("vbox/menuBarControl")));
        if (PlatformService.osName == "macOS") {
            menuBarControl.customMinimumSize = new Vector2(0, 0);
        }
        
        var args = Sys.args();
        for (arg in args) {
            if (StringTools.endsWith(arg, ".snbproj")) {
                snbProjPath = arg;
                break;
            }
        }

        try {
            if (snbProjPath != "") {
                var snbProjPathArray = snbProjPath.split("\\").join("/").split("/");
                if (snbProjPathArray.length > 0) {
                    var projectDirectory = snbProjPathArray.slice(0, snbProjPathArray.length - 1).join("/");
                    trace("Project Directory: " + projectDirectory);
                    projectTree = new ProjectTree(this);
                    projectTree.projectDirectory = projectDirectory;
                    projectTree.init();
                }
            }
        }
        catch (e:Dynamic) {
            trace("Error initializing ProjectTree: " + e);
            throw e;
        }
    }
}