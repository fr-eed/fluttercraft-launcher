import 'dart:ffi';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

part 'enums.g.dart';

// ignore: constant_identifier_names
enum CraftVersionType { snapshot, release, old_beta, old_alpha }

@JsonSerializable(explicitToJson: true)
class _JreComponentEnumWrapper {
  JreComponent name;
  _JreComponentEnumWrapper(this.name);
}

@JsonEnum()
enum JreComponent {
  @JsonValue("java-runtime-alpha")
  javaRuntimeAlpha,
  @JsonValue("java-runtime-beta")
  javaRuntimeBeta,
  @JsonValue("java-runtime-delta")
  javaRuntimeDelta,
  @JsonValue("java-runtime-gamma")
  javaRuntimeGamma,
  @JsonValue("java-runtime-gamma-snapshot")
  javaRuntimeGammaSnapshot,
  @JsonValue("jre-legacy")
  jreLegacy,
  @JsonValue("minecraft-java-exe")
  minecraftJavaExe,

  @JsonValue("other")
  other;

  String get name {
    return _$JreComponentEnumMap[this]!;
  }

  static JreComponent fromString(String name) {
    return $enumDecode(_$JreComponentEnumMap, name);
  }
}

@JsonSerializable(explicitToJson: true)
class _JrePlatformEnumWrapper {
  JrePlatform name;
  _JrePlatformEnumWrapper(this.name);
}

@JsonEnum()
enum JrePlatform {
  @JsonValue("linux")
  linuxX64,
  @JsonValue("linux-i386")
  linuxX86,

  @JsonValue("windows-x64")
  windowsX64,
  @JsonValue("windows-x86")
  windowsX86,
  @JsonValue("windows-arm64")
  windowsArm64,

  @JsonValue("mac-os")
  macosX64,
  @JsonValue("mac-os-arm64")
  macosArm64,

  // unsupported currently but maybe in the future
  @JsonValue("gamecore")
  gamecore,

  // unsupported currently but maybe in the future
  @JsonValue("other")
  other;

  String get name {
    return _$JrePlatformEnumMap[this]!;
  }

  static JrePlatform getSystemJreOs() {
    final os = OsType.getSystemOS();
    final arch = OsArch.getSystemArchitecture();

    switch (os) {
      case OsType.windows:
        switch (arch) {
          case OsArch.x64:
            return JrePlatform.windowsX64;
          case OsArch.x86:
            return JrePlatform.windowsX86;
          case OsArch.arm64:
            return JrePlatform.windowsArm64;
          default:
            return JrePlatform.windowsX64;
        }
      case OsType.linux:
        switch (arch) {
          case OsArch.x64:
            return JrePlatform.linuxX64;
          case OsArch.x86:
            return JrePlatform.linuxX86;
          default:
            return JrePlatform.linuxX64;
        }
      case OsType.osx:
        switch (arch) {
          case OsArch.x64:
            return JrePlatform.macosX64;
          case OsArch.arm64:
            return JrePlatform.macosArm64;
          default:
            return JrePlatform.macosX64;
        }
    }
  }
}

enum OsArch {
  x64,
  x86,
  arm64,
  unknown;

  static OsArch getSystemArchitecture() {
    switch (Abi.current()) {
      case Abi.linuxArm64:
      case Abi.androidArm64:
      case Abi.linuxArm:
      case Abi.androidArm:
      case Abi.windowsArm64:
      case Abi.macosArm64:
        return arm64;
      case Abi.linuxX64:
      case Abi.windowsX64:
      case Abi.macosX64:
        return x64;
      case Abi.linuxIA32:
      case Abi.windowsIA32:
        return x86;
      default:
        throw Exception("Unsupported Architecture");
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
