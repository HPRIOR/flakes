# Nix Flake Templates

A collection of Nix flake templates for various development environments.

## Quick Start

Initialize a new project with a single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/HPRIOR/flakes/main/init.sh) <app-name>
```

This will:
1. Present a menu to select a template (rust or minimal)
2. Initialize the selected template in the current directory
3. Replace all instances of 'templated' with your app name
4. Initialize a git repository (if needed)
5. Enable direnv for automatic environment activation

### Example

```bash
mkdir my-project && cd my-project
bash <(curl -s https://raw.githubusercontent.com/HPRIOR/flakes/main/init.sh) <app-name>
```

## Available Templates

### Rust
A Rust development environment with cargo and toolchain configured.

```bash
nix flake init -t github:HPRIOR/flakes#rust
```

### Minimal
A minimal flake template with just nixpkgs - perfect as a starting point for custom environments.

```bash
nix flake init -t github:HPRIOR/flakes#minimal
```

## Template Structure

### Rust Template
- Complete Rust development setup
- Includes `rust-toolchain.toml` for toolchain configuration
- Sample project structure with `src/main.rs` and tests
- Pre-configured `Cargo.toml`

### Minimal Template
- Basic flake structure with nixpkgs input
- Clean starting point for custom development environments

## Manual Usage

Alternatively, you can initialize templates manually using nix commands:

1. Choose a template and initialize it in your project directory
2. Run `direnv allow` if you use direnv
3. The development environment will be automatically available

## Requirements

- Nix with flakes enabled
- direnv (optional, but recommended for automatic environment activation)
- git
