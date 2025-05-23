{
  description = "Flutter for Android development by CrystalNetwork Studio";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersion = "34.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          includeEmulator = false;
          includeSystemImages = false;
          buildToolsVersions = [
            buildToolsVersion
            "33.0.1"
            "28.0.3"
          ];
          platformVersions = [
            "35"
            "34"
            "28"
          ];
          abiVersions = [
            "armeabi-v7a"
            "arm64-v8a"
          ];
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell =
          with pkgs;
          mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            buildInputs = [
              flutter327
              androidSdk
              jdk17
              
              # For Build Desktop
              clang
              cmake
              ninja
              pkg-config
              gtk3
            ];
          };
      }
    );
}
