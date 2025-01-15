import 'dart:ffi';
import 'dart:io';

enum CraftVersionType { snapshot, release }

enum OsArch {
  x64,
  x86,
  arm,
  unknown;

  static OsArch getSystemArchitecture() {
    switch (Abi.current()) {
      case Abi.linuxArm64:
      case Abi.androidArm64:
      case Abi.linuxArm:
      case Abi.androidArm:
      case Abi.windowsArm64:
      case Abi.macosArm64:
        return arm;
      case Abi.linuxX64:
      case Abi.windowsX64:
      case Abi.macosX64:
        return x64;
      case Abi.linuxIA32:
      case Abi.windowsIA32:
        return x86;
      default:
        return unknown;
    }
  }
}

enum OsType {
  windows,
  linux,
  osx;

  static OsType getSystemOS() {
    if (Platform.isWindows) {
      return OsType.windows;
    } else if (Platform.isLinux) {
      return OsType.linux;
    } else if (Platform.isMacOS) {
      return OsType.osx;
    } else {
      throw Exception("Unsupported OS");
    }
  }
}

enum RuleAction {
  allow,
  disallow,
}
