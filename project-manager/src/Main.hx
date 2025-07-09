package;

import sunaba.App;

class Main extends App {
    public static function main() {
        new Main();
    }

    override function init() {
        try {
            var player = new ProjectManager();
            rootElement.addChild(player.rootElement);
        } catch (e:Dynamic) {
            trace("Error initializing Player: " + e);
            throw e;
        }
    }
}