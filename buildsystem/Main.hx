package;
import sys.FileSystem;
import sys.io.File;

class Main {
    static var godotCommand = "godot";

    static var targetPlatform = "";

    static var exportType = ExportType.debug;

    static var packageFormat = PackageFormat.none;

    static var targetName: String = "";

    public static function main() {
        var args = Sys.args();

        if (args[0] == "-h" || args[0] == "--help") {
            Sys.println("Usage: node build [run|export] [--godot-command=<command>] [--target=<platform>] [-debug|-release]");
            Sys.println("  run: Run the Sunaba Player");
            Sys.println("  --godot-command=<command>: Specify the Godot command to use (default: godot)");
            Sys.println("  --skip: Skip the build step");
            Sys.println("  export: Export the Sunaba Player for the specified platform");
            Sys.println("  --skip -s: Skip the build step");
            Sys.println("  --godot-command=<command>: Specify the Godot command to use (default: godot)");
            Sys.println("  --target=<platform> -t=<platform>: Specify the target platform (default: auto-detect based on OS)");
            Sys.println("  --debug -d: Export in debug mode");
            Sys.println("  --release -r: Export in release mode");
            Sys.println("  --pkgformat=<format> -p: Specify the package format (none, nsis, deb, dmg)");
            return;
        }

        if (args[0] == "install") {
            if (Sys.systemName() == "Linux") {
                exportType = ExportType.release;
                var usrPath = "/usr/";
                setupBin();
                buildUnixUsrDir(usrPath);
                return;
            }
        }

        var currentDir = Sys.getCwd();
        if (StringTools.contains(currentDir, "\\"))
            currentDir = StringTools.replace(currentDir, "\\", "/");

        var skipBuild = false;

        for (i in 0...args.length) {
            var arg = args[i];
            if (StringTools.startsWith(arg, "--godot-command=")) {
                godotCommand = StringTools.replace(arg, "--godot-command=", "");
                Sys.println("Using godot command: " + godotCommand);
            }
            else if (StringTools.startsWith(arg, "--target=")) {
                targetPlatform = StringTools.replace(arg, "--target=", "");
            }
            else if (arg == "--debug" || arg == "-d") {
                exportType = ExportType.debug;
            }
            else if (arg == "--release" || arg == "-r") {
                exportType = ExportType.release;
            }
            else if (arg == "--skip" || arg == "-s") {
                skipBuild = true;
            }
            else if (StringTools.startsWith(arg, "--pkgformat=")) {
                var format = StringTools.replace(arg, "--pkgformat=", "");
                if (format != "") {
                    if (format == "nsis") {
                        packageFormat = PackageFormat.nsis;
                    }
                    else if (format == "deb" || format == "debian") {
                        packageFormat = PackageFormat.deb;
                    }
                    else if (format == "dmg") {
                        packageFormat = PackageFormat.dmg;
                    }
                    else {
                        Sys.println("Unknown package format: " + format);
                        Sys.exit(-1);
                    }
                }
            }
            else if (StringTools.startsWith(arg, "-t=")) {
                targetPlatform = StringTools.replace(arg, "-t=", "");
            }
            else if (StringTools.startsWith(arg, "-p=")) {
                var format = StringTools.replace(arg, "-p=", "");
                if (format != "") {
                    if (format == "nsis") {
                        packageFormat = PackageFormat.nsis;
                    }
                    else if (format == "deb" || format == "debian") {
                        packageFormat = PackageFormat.deb;
                    }
                    else if (format == "dmg") {
                        packageFormat = PackageFormat.dmg;
                    }
                    else {
                        Sys.println("Unknown package format: " + format);
                        Sys.exit(-1);
                    }
                }
            }
        }

        var tsukuru = new Tsukuru();
        tsukuru.zipOutputPath = currentDir + "template/player.sbx";
        if (!skipBuild) {
            tsukuru.build(currentDir + "player.snbproj");
        }
        else {
            Sys.println("Skipping build step.");
        }


        if (args[0] == "run") {
            run();
            return;
        }
        else if (args[0] == "export") {
            export();
        }

        if (packageFormat == PackageFormat.nsis) {
            buildNsisInstaller();
        }
        else if (packageFormat == PackageFormat.deb) {
            createDebPackage();
        }
        else if (packageFormat == PackageFormat.dmg) {
            exportDmg();
        }
    }

    public static function run() {
        var result = Sys.command(godotCommand + " --path ./template");
        Sys.exit(result);
    }

    public static function setupBin() {
        if (targetPlatform == "") {
            var systemName =  Sys.systemName();
            if (systemName == "Windows") {
                targetPlatform = "windows-amd64";
            }
            else if (systemName == "Mac") {
                targetPlatform = "mac-universal";
            }
            else if (systemName == "Linux") {
                targetPlatform = "linux-amd64";
            }
        }
        if (targetPlatform == "mac-universal") {
            targetName = "Sunaba Player.app";
        }
        else if (targetPlatform == "windows-amd64") {
            targetName = "SunabaPlayer.exe";
        }
        else if (targetPlatform == "linux-amd64") {
            targetName = "sunaba-player";
        }
        else {
            Sys.println("Invalid target: " + targetPlatform);
            Sys.exit(-1);
        }

        var rootPath = Sys.getCwd() + "bin";
        if (!FileSystem.exists(rootPath)) {
            FileSystem.createDirectory(rootPath);
        }

        var targetPath = rootPath + "/" + targetPlatform + "-" + exportType;
        if (!FileSystem.exists(targetPath)) {
            FileSystem.createDirectory(targetPath);
        }
    }

    public static function export() {
        setupBin();

        Sys.println("Exporting for target platform: " + targetPlatform);
        Sys.println("Exporting for " + exportType);

        var command = godotCommand + " --path ./template --headless --editor --export-" + exportType + " \"" + targetPlatform + "\" \"../bin/" + targetPlatform + "-" + exportType + "/" + targetName + "\"";
        //trace(command);

        var result = Sys.command(command);
        if (result != 0) {
            trace("Godot export failed with code " + result);
            Sys.println(godotCommand + " exited with code " + result);
            Sys.exit(result);
        }
    }

    public static function buildNsisInstaller() {
        var nsisCommand = "makensis";
        if (Sys.systemName() == "Windows") {
            if (Sys.command(nsisCommand + " /VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        }
        else if (Sys.systemName() == "Linux" || Sys.systemName() == "Mac") {
            nsisCommand = "makensis";
            if (Sys.command(nsisCommand + " -VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        }

        var outputInstallerPath = Sys.getCwd() + "bin/" + targetPlatform + "-" + exportType + "-nsis/SunabaPlayerInstaller.exe";

        if (!FileSystem.exists(Sys.getCwd() + "/bin/" + targetPlatform + "-" + exportType + "-nsis")) {
            FileSystem.createDirectory(Sys.getCwd() + "/bin/" + targetPlatform + "-" + exportType + "-nsis");
        }

        var nsisScript = "setup.nsi";
        if (exportType == ExportType.debug) {
            nsisScript = "setup-debug.nsi";
        }

        var command = nsisCommand + " " + nsisScript;
        trace("Running NSIS command: " + command);
        var result = Sys.command(command);
        if (result != 0) {
            Sys.println("NSIS installer creation failed with code " + result);
            Sys.exit(result);
        }

        Sys.println("NSIS installer created at: " + outputInstallerPath);
    }

    public static function createDebPackage() {
        var cwd = Sys.getCwd();

        if (!StringTools.endsWith(cwd, "/")) {
            cwd += "/";
        }

        var debRootPath = cwd + ".debian/";
        if (!FileSystem.exists(debRootPath)) {
            FileSystem.createDirectory(debRootPath);
        }

        var debPackagePath = debRootPath + "sunaba-player-" + exportType + "/";
        if (!FileSystem.exists(debPackagePath)) {
            FileSystem.createDirectory(debPackagePath);
        }

        var debUsrPath = debPackagePath + "usr/";
        if (!FileSystem.exists(debUsrPath)) {
            FileSystem.createDirectory(debUsrPath);
        }

        buildUnixUsrDir(debUsrPath);

        var debDebianPath = debPackagePath + "DEBIAN/";
        if (!FileSystem.exists(debDebianPath)) {
            FileSystem.createDirectory(debDebianPath);
        }

        var cwdDebianFilesPath = cwd + "debian_files/";

        File.copy(cwdDebianFilesPath + "control", debDebianPath + "control");
        //File.copy(cwdDebianFilesPath + "postinst", debDebianPath + "postinst");
        //File.copy(cwdDebianFilesPath + "preinst", debDebianPath + "preinst");
        //File.copy(cwdDebianFilesPath + "changelog", debDebianPath + "changelog");
        File.copy(cwd + "LICENSE", debDebianPath + "copyright");

        var result = Sys.command("dpkg-deb --build " + debPackagePath);

        if (result != 0) {
            Sys.println("dpkg-deb failed at " + result);
        }

        var debOutputPath = cwd + "bin/" + targetPlatform + "-" + exportType + "-deb/";
        if (!FileSystem.exists(debOutputPath)) {
            FileSystem.createDirectory(debOutputPath);
        }

        var debPackageName = "sunaba-player-" + exportType + ".deb";

        File.copy(debRootPath + debPackageName, debOutputPath + debPackageName);
    }

    public static function buildUnixUsrDir(path: String) {
        var cwd = Sys.getCwd();
        if (!StringTools.endsWith(cwd, "/")) {
            cwd += "/";
        }
        var rootPath = cwd + "bin";
        var exportPath = rootPath + "/" + targetPlatform + "-" + exportType + "/";

        if (!StringTools.endsWith(path, "/")) {
            path += "/";
        }

        var binPath = path + "bin/";
        var libPath = path + "lib/";
        var sharePath = path + "share/";
        var shareSunabaPath = sharePath + "sunaba/";
        var shareApplicationsPath = sharePath + "applications/";
        var sharePixmapsPath = sharePath + "pixmaps/";

        if (!FileSystem.exists(binPath)) {
            FileSystem.createDirectory(binPath);
        }
        if (!FileSystem.exists(libPath)) {
            FileSystem.createDirectory(libPath);
        }
        if (!FileSystem.exists(sharePath)) {
            FileSystem.createDirectory(sharePath);
        }
        if (!FileSystem.exists(shareSunabaPath)) {
            FileSystem.createDirectory(shareSunabaPath);
        }
        if (!FileSystem.exists(shareApplicationsPath)) {
            FileSystem.createDirectory(shareApplicationsPath);
        }
        if (!FileSystem.exists(sharePixmapsPath)) {
            FileSystem.createDirectory(sharePixmapsPath);
        }

        var executableName = "sunaba-player";
        File.copy(exportPath + executableName, binPath + executableName);

        var libraryName = "libsunaba.so";
        if (exportType == ExportType.debug) {
            libraryName = "libsunaba-d.so";
        }
        File.copy(exportPath + libraryName, libPath + libraryName);

        File.copy(exportPath + "player.sbx", shareSunabaPath + "player.sbx");
        File.copy(exportPath + "mobdebug.lua", shareSunabaPath + "mobdebug.lua");
        File.copy(cwd + "sunaba-player.desktop", shareApplicationsPath + "sunaba-player.desktop");
        File.copy(cwd + "sunaba.png", sharePixmapsPath + "sunaba.png");
    }

    public static function exportDmg() {
        var applicationsFolder = "/Applications/";
        Sys.command("ln -s /Applications/ " + Sys.getCwd() + "/bin/" + targetPlatform + "-" + exportType + "/Applications");
        Sys.command("hdiutil create -volname 'Sunaba Player' -srcfolder 'bin/" + targetPlatform + "-" + exportType + "' -ov -format UDZO 'bin/sunaba-player-" + exportType + ".dmg'");
        Sys.println("DMG package created at: bin/sunaba-player-" + exportType + ".dmg");
        var dmgPath = Sys.getCwd() + "bin/sunaba-player-" + exportType + ".dmg";
        if (!FileSystem.exists(dmgPath)) {
            Sys.println("DMG package creation failed.");
            Sys.exit(-1);
        } else {
            Sys.println("DMG package created successfully at: " + dmgPath);
        }
    }
}