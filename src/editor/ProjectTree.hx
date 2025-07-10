package editor;

class ProjectTree {
    public var editor: Editor;

    public var projectDirectory: String = "";

    public function new(editor: Editor) {
        this.editor = editor;
    }

    public function init() {
        // Initialize the project tree here
        // This could involve loading the project structure, setting up event listeners, etc.
        trace("ProjectTree initialized with directory: " + projectDirectory);
    }
}