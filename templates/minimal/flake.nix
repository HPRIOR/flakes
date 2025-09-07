{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        templated_app = pkgs.stdenv.mkDerivation {
          pname = "templated_app";
          version = "0.1.0";
          src = ./.;
          installPhase = ''
            mkdir -p $out/bin
            echo '#!/bin/sh' > $out/bin/templated_app
            echo 'echo "Hello from templated_app!"' >> $out/bin/templated_app
            chmod +x $out/bin/templated_app
          '';
        };
        default = self.packages.${system}.templated_app;
      }
    );

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
          ];

          shellHook = ''
            echo "Welcome to the development shell!"
          '';
        };
      }
    );
  };
}
