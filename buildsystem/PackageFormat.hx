package;

enum abstract PackageFormat(String) from String to String {
    var none = "none";
    var nsis = "nsis";
    var deb = "deb";
    var dmg = "dmg";
}