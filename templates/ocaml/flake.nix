{
  description = "templated";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";

    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.opam-repository.follows = "opam-repository";
    };

    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false; # plain Git repo, not a flake
    };
  };

  outputs = {
    self,
    nixpkgs,
    opam-nix,
    flake-utils,
    ...
  }: let
    pname = "templated";
    ocamlVersion = "5.2.1";
  in
    flake-utils.lib.eachDefaultSystem (system:
      with opam-nix.lib.${system}; let
        pkgs = nixpkgs.legacyPackages.${system};
        drv = buildDuneProject {} pname ./templated {
          ocaml-base-compiler = ocamlVersion;
          dune = "*"; # ensure dune is present
          utop = "*"; # REPL (optional)
          ocaml-lsp-server = "*"; # editor LSP (optional)
        };
      in {
        # ‘nix build .’
        packages = {
          ${pname} = drv.${pname};
          default = drv.${pname};
        };

        # 'nix run'
        apps.default = flake-utils.lib.mkApp {
          drv = drv.${pname};
        };

        # 'nix flake check'
        checks.default = drv.${pname};

        # 'nix develop'
        devShells.default = pkgs.mkShell {
          # inherit ALL libraries/compilers from our project
          inputsFrom = [drv.${pname}];

          buildInputs = [
            pkgs.ocamlformat
            pkgs.merlin or null
            drv.ocaml-lsp-server # LSP brought in via opam-nix
            drv.utop # REPL
          ];
        };
      });
}
