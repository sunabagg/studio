package;

enum abstract ExportType(String) from String to String {
    var release = "release";
    var debug = "debug";
}