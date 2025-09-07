# Nix Flake Templates

A collection of Nix flake templates for various development environments.

## Quick Start

Initialize a new project with a single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/HPRIOR/flakes/main/init.sh) <app-name> <project-type>
```

## Available Templates

### Rust

A Rust development environment with cargo and toolchain configured.

```bash
nix flake init -t github:HPRIOR/flakes#rust
```

### OCaml

An OCaml development environment with compiler, dune build system, and development tools configured.

```bash
nix flake init -t github:HPRIOR/flakes#ocaml
```

### Minimal

A minimal flake template with just nixpkgs - perfect as a starting point for custom environments.

```bash
nix flake init -t github:HPRIOR/flakes#minimal
```

## Requirements

- Nix with flakes enabled
- direnv (optional, but recommended for automatic environment activation)
- git
