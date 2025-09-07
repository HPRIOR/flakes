#!/bin/sh
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    color=$1
    shift
    printf "${color}%s${NC}\n" "$*"
}

# Function to print error and exit
error_exit() {
    print_color "$RED" "Error: $1" >&2
    exit 1
}

# Check if app name is provided
if [ $# -eq 0 ]; then
    error_exit "Please provide an application name as an argument"
fi

APP_NAME="$1"
TEMPLATE="$2"

# Validate app name (alphanumeric, underscore, and hyphen only)
if ! echo "$APP_NAME" | grep -qE '^[a-zA-Z0-9_-]+$'; then
    error_exit "Application name can only contain letters, numbers, underscores, and hyphens"
fi

print_color "$BLUE" "=== Nix Flake Project Initializer ==="
print_color "$GREEN" "Application name: $APP_NAME"
echo

# Check if current directory is empty (except for .git)
if [ "$(ls -A 2>/dev/null | grep -v '^\.git$' | wc -l)" -gt 0 ]; then
    print_color "$YELLOW" "Warning: Current directory is not empty."
    printf "Continue anyway? (y/N): "
    read -r response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        print_color "$RED" "Aborted."
        exit 1
    fi
fi

# Handle template selection - check if provided as argument
if [ -n "$TEMPLATE" ]; then
    # Template provided as argument - validate it
    case $TEMPLATE in
        rust|minimal)
            print_color "$GREEN" "Using template: $TEMPLATE"
            ;;
        *)
            error_exit "Invalid template '$TEMPLATE'. Valid options are: rust, minimal"
            ;;
    esac
else
    # No template provided - interactive selection
    print_color "$BLUE" "Available templates:"
    echo "1) rust     - Rust development environment with cargo and toolchain"
    echo "2) minimal  - Minimal flake with just nixpkgs"
    echo
    printf "Select a template (1-2): "
    read -r choice

    # Map choice to template name
    case $choice in
        1)
            TEMPLATE="rust"
            print_color "$GREEN" "Selected: Rust template"
            ;;
        2)
            TEMPLATE="minimal"
            print_color "$GREEN" "Selected: Minimal template"
            ;;
        *)
            error_exit "Invalid selection. Please choose 1 or 2."
            ;;
    esac
fi

echo

# Initialize the flake template from GitHub
print_color "$BLUE" "Initializing template..."
if ! nix flake init -t "github:HPRIOR/flakes#$TEMPLATE" 2>/dev/null; then
    # Fallback to git URL if GitHub shorthand doesn't work
    if ! nix flake init -t "git+https://github.com/HPRIOR/flakes#$TEMPLATE" 2>/dev/null; then
        error_exit "Failed to initialize template. Please ensure nix is installed and the repository is accessible."
    fi
fi

print_color "$GREEN" "✓ Template initialized"

# Replace all instances of 'templated' with the app name
print_color "$BLUE" "Replacing 'templated' with '$APP_NAME'..."

# Function to replace in files
replace_in_files() {
    # Find all text files and replace templated
    find . -type f \( \
        -name "*.nix" -o \
        -name "*.toml" -o \
        -name "*.lock" -o \
        -name "*.rs" -o \
        -name "*.md" -o \
        -name "*.txt" -o \
        -name "*.yaml" -o \
        -name "*.yml" -o \
        -name "*.json" \
    \) -not -path "./.git/*" -not -path "./target/*" 2>/dev/null | while IFS= read -r file; do
        if grep -q "templated" "$file" 2>/dev/null; then
            # Use sed with different delimiter to avoid issues with slashes in paths
            sed -i.bak "s|templated|$APP_NAME|g" "$file" && rm -f "$file.bak"
            print_color "$GREEN" "  ✓ Updated: $file"
        fi
    done
}

replace_in_files

# Rename files and directories containing 'templated'
print_color "$BLUE" "Renaming files and directories..."

# Function to rename files and directories
rename_items() {
    # First rename files
    find . -type f -name "*templated*" -not -path "./.git/*" 2>/dev/null | while IFS= read -r file; do
        newname=$(echo "$file" | sed "s|templated|$APP_NAME|g")
        if [ "$file" != "$newname" ]; then
            mv "$file" "$newname"
            print_color "$GREEN" "  ✓ Renamed: $file -> $newname"
        fi
    done
    
    # Then rename directories (bottom-up to avoid issues with nested dirs)
    find . -type d -name "*templated*" -not -path "./.git/*" 2>/dev/null | sort -r | while IFS= read -r dir; do
        newname=$(echo "$dir" | sed "s|templated|$APP_NAME|g")
        if [ "$dir" != "$newname" ] && [ -d "$dir" ]; then
            mv "$dir" "$newname"
            print_color "$GREEN" "  ✓ Renamed: $dir -> $newname"
        fi
    done
}

rename_items

# Initialize git repository if it doesn't exist
if [ ! -d .git ]; then
    print_color "$BLUE" "Initializing git repository..."
    git init >/dev/null 2>&1
    git add . >/dev/null 2>&1
    print_color "$GREEN" "✓ Git repository initialized and files added"
else
    print_color "$YELLOW" "Git repository already exists, skipping initialization"
fi

# Run direnv allow
print_color "$BLUE" "Enabling direnv..."
if command -v direnv >/dev/null 2>&1; then
    direnv allow >/dev/null 2>&1
    print_color "$GREEN" "✓ direnv enabled"
else
    print_color "$YELLOW" "direnv not found. Please install direnv and run 'direnv allow' manually."
fi

# Success message
echo
print_color "$GREEN" "========================================="
print_color "$GREEN" "✓ Project '$APP_NAME' initialized successfully!"
print_color "$GREEN" "========================================="
echo
print_color "$BLUE" "Next steps:"
echo "  1. If direnv is not installed: install it and run 'direnv allow'"
echo "  2. Start developing with your new $TEMPLATE project!"
if [ "$TEMPLATE" = "rust" ]; then
    echo "  3. Try running: cargo run"
fi
echo
print_color "$YELLOW" "Note: The development environment will be automatically activated by direnv."