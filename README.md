# Nix Flake Templates

A collection of Nix flake templates for various development environments.

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

## Usage

1. Choose a template and initialize it in your project directory
2. Run `direnv allow` if you use direnv
3. The development environment will be automatically available