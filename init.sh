#!/bin/bash

set -euo pipefail

# Function to capitalize first letter of a string
capitalize_first() {
    local input="$1"
    if [[ ${#input} -gt 0 ]]; then
        echo "${input^}"
    else
        echo "$input"
    fi
}

# Function to replace templated strings in files
replace_templated_strings() {
    local app_name="$1"
    local capitalized_app_name
    capitalized_app_name=$(capitalize_first "$app_name")
    
    # Find all files and replace templated strings
    find . -type f -exec grep -l '[Tt]emplated' {} \; 2>/dev/null | while read -r file; do
        if [[ -f "$file" ]]; then
            # Replace 'Templated' (capitalized) with capitalized app name
            sed -i "s/Templated/$capitalized_app_name/g" "$file"
            # Replace 'templated' (lowercase) with lowercase app name
            sed -i "s/templated/$app_name/g" "$file"
            echo "Updated strings in: $file"
        fi
    done
}

# Function to rename files and directories containing 'templated'
rename_templated_paths() {
    local app_name="$1"
    local capitalized_app_name
    capitalized_app_name=$(capitalize_first "$app_name")
    
    # Rename files and directories (depth-first to avoid issues with parent directories)
    # Using -depth ensures we rename children before parents
    find . -depth -name '*[Tt]emplated*' | while read -r path; do
        if [[ -e "$path" ]]; then
            local dir_name
            dir_name=$(dirname "$path")
            local base_name
            base_name=$(basename "$path")
            
            # Handle both lowercase and capitalized replacements
            local new_name="$base_name"
            new_name=${new_name//Templated/$capitalized_app_name}
            new_name=${new_name//templated/$app_name}
            
            local new_path="$dir_name/$new_name"
            
            if [[ "$path" != "$new_path" ]]; then
                mv "$path" "$new_path"
                echo "Renamed: $path -> $new_path"
            fi
        fi
    done
}

# Main script
main() {
    # Check arguments
    if [[ $# -ne 2 ]]; then
        echo "Usage: $0 <app-name> <project-type>"
        echo "Available project types: rust, minimal, ocaml"
        exit 1
    fi
    
    local app_name="$1"
    local project_type="$2"
    
    # Validate app name (basic validation)
    if [[ ! "$app_name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        echo "Error: App name must start with a letter and contain only letters, numbers, hyphens, and underscores"
        exit 1
    fi
    
    # Validate project type
    case "$project_type" in
        rust|minimal|ocaml)
            ;;
        *)
            echo "Error: Invalid project type '$project_type'"
            echo "Available project types: rust, minimal, ocaml"
            exit 1
            ;;
    esac
    
    echo "Initializing $project_type template for '$app_name'..."
    
    # Initialize the flake template
    if ! nix flake init -t "github:HPRIOR/flakes#$project_type"; then
        echo "Error: Failed to initialize flake template"
        exit 1
    fi
    
    echo "Template initialized successfully"
    
    # Replace templated strings in files
    echo "Replacing templated strings with '$app_name'..."
    replace_templated_strings "$app_name"
    
    # Rename files and directories
    echo "Renaming templated files and directories..."
    rename_templated_paths "$app_name"
    
    echo "Project '$app_name' has been successfully initialized with template '$project_type'"
    echo "You can now start developing in your new project!"
}

# Run main function with all arguments
main "$@"