{
  description = "Development environment templates";

  outputs = {self}: {
    templates = {
      rust = {
        path = ./templates/rust;
        description = "Rust development environment with cargo and toolchain";
        welcomeText = ''
          # Rust Development Environment

          ## Getting started
          ```bash
          direnv allow
          cargo run
          ```
        '';
      };

      minimal = {
        path = ./templates/minimal;
        description = "Minimal flake with just nixpkgs";
      };
    };
  };
}
