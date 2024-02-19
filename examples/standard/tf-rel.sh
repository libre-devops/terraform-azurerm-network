#!/usr/bin/env bash

########################################################
# Script Usage:
# By default, this script runs in 'manual mode' (tf-rel function).
#
# Options:
#   -m or --manual-mode   : (default behavior) Executes the tf-rel function.
#   -a or --append        : Appends the tf-rel function to the user's .bashrc.
#   -v or --version X.X.X : Sets a specific version tag when running tf-rel.
#                           Replace 'X.X.X' with the desired version number.
########################################################

function stfi () {
    curl https://raw.githubusercontent.com/cyber-scot/utilities/main/terraform/helpers/tf-sort.sh | bash -s -- variables.tf variables.tf
}

function stfo () {
    curl https://raw.githubusercontent.com/cyber-scot/utilities/main/terraform/helpers/tf-sort.sh | bash -s -- outputs.tf outputs.tf
}

function tf-rel() {
    print_success() {
        lightcyan='\033[1;36m'
        nocolor='\033[0m'
        echo -e "${lightcyan}$1${nocolor}"
    }

    print_error() {
        lightred='\033[1;31m'
        nocolor='\033[0m'
        echo -e "${lightred}$1${nocolor}"
    }

    print_alert() {
        yellow='\033[1;33m'
        nocolor='\033[0m'
        echo -e "${yellow}$1${nocolor}"
    }

    local curdir=$(basename "$(pwd)")
    local build_file=""
    if [ -f build.tf ]; then
        build_file="build.tf"
        print_success "${build_file} found"
    elif [ -f main.tf ]; then
        build_file="main.tf"
        print_success "${build_file} found"
    fi
    if [ "$build_file" != "" ]; then
        echo "" > README.md
        echo '```hcl' >> README.md
        cat "$build_file" >> README.md
        echo '```' >> README.md
    else
        print_alert "Not a build directory, no build.tf or main.tf found"
    fi
    terraform fmt -recursive
    terraform-docs markdown . >> README.md
    stfi && \
    stfo
    git add --all
    git commit -m "Update module"
    git push
    local tag_version=${VERSION:-1.0.0}
    git tag $tag_version --force
    git push --tags --force
}

function append_to_bashrc() {
    echo "Appending functions to .bashrc"
    echo "" >>~/.bashrc
    echo "# Define tf-rel function" >>~/.bashrc
    declare -f tf-rel >>~/.bashrc
}

# Flag to determine if any option is set
OPTION_SET=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--manual-mode)
            OPTION_SET=true
            shift
            ;;
        -a|--append)
            append_to_bashrc
            OPTION_SET=true
            shift
            ;;
        -v|--version)
            if [[ "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                VERSION="$2"
                OPTION_SET=true
                shift 2
            else
                echo "Error: Invalid version format. Please use the format X.X.X"
                exit 1
            fi
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# If no recognized option is set, run in manual mode by default
if [ "$OPTION_SET" = false ]; then
    tf-rel
fi
