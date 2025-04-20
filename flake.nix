{
  description = "A Nix Flake for Flutter development";

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
            allowUnfree = true;
          };
        };
        lib = pkgs.lib;
        linuxDeps = lib.optionals pkgs.stdenv.isLinux (
          with pkgs;
          [
            clang
            cmake
            ninja
            pkg-config
            gtk3
          ]
        );

        # Dependencies for macOS
        darwinDeps = lib.optionals pkgs.stdenv.isDarwin (
          with pkgs;
          [
            cocoapods
            ios-deploy
          ]
        );
        shellPackages =
          with pkgs;
          [
            # Core Flutter
            flutter
            # Basic tools
            git
            jq
            which
          ]
          ++ linuxDeps
          ++ darwinDeps;

      in
      {
        devShells.default = pkgs.mkShell {
          name = "flutter-dev-shell";

          packages = shellPackages;

          shellHook = ''
            # Changed Welcome Message
            echo "--- Flutter Development Shell ---"
            # add Flutter to PATH
            export PATH="${lib.makeBinPath shellPackages}:$PATH"

            # For MacOS
            ${lib.optionalString pkgs.stdenv.isDarwin ''
              echo "macOS detected:"
              echo " - Ensure Xcode is installed and configured."
              echo " - Check 'flutter doctor' for CocoaPods status."
              echo ""
            ''}

            # Changed message
            echo "Run 'flutter doctor -v' to check your setup (Android toolchain will be missing)."
            echo "-------------------------------------------------------"
          '';
        };
      }
    );
}