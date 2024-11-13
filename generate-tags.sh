#!/bin/bash
set -eo pipefail

# Simplify directory references
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT_DIR="$SCRIPT_DIR"

# Default values
DOCKER_ORGANIZATIONS="${DOCKER_ORGANIZATIONS:-"docker.io/serversideup ghcr.io/serversideup"}"
DOCKER_REPOSITORY_NAME="${DOCKER_REPOSITORY_NAME:-"ssh"}"
GITHUB_REF_NAME="${GITHUB_REF_NAME:-""}"
PRINT_TAGS_ONLY=false
RELEASE_TYPE="dev"
VERSION=""

##################################################
# Functions
##################################################

add_tag() {
    local new_tag="$1"
    local prefix=""

    # Set prefix based on RELEASE_TYPE
    if [ "$RELEASE_TYPE" != "latest" ]; then
        prefix="${RELEASE_TYPE}-"
    fi

    # Prevent duplicate prefixes
    if [[ "$new_tag-" == "$prefix" ]]; then
        prefix=""
    fi

    # Construct the full tag
    full_tag="${prefix}${new_tag}"

    # Add tags for each Docker organization
    for org in $DOCKER_ORGANIZATIONS; do
        if [ -n "$GITHUB_REF_NAME" ] && [ "$RELEASE_TYPE" == "pr" ]; then
            tags+=("${org}/${DOCKER_REPOSITORY_NAME}:${full_tag}-${GITHUB_REF_NAME}")
            break
        fi
        tags+=("${org}/${DOCKER_REPOSITORY_NAME}:${full_tag}")
        if [ -n "$GITHUB_REF_NAME" ] && [ "${full_tag}" != "$RELEASE_TYPE" ] && [ "$GITHUB_REF_TYPE" == "tag" ]; then
            tags+=("${org}/${DOCKER_REPOSITORY_NAME}:${full_tag}-${GITHUB_REF_NAME}")
        fi
    done
}

generate_tags() {
    local tags=()

    if [ -n "$VERSION" ]; then
        # Strip 'v' prefix if present
        VERSION="${VERSION#v}"
        
        # Split version into major, minor, patch
        local major=$(echo "$VERSION" | cut -d. -f1)
        local minor=$(echo "$VERSION" | cut -d. -f2)
        local patch=$(echo "$VERSION" | cut -d. -f3)

        # Add all version tags
        add_tag "v${major}.${minor}.${patch}"  # v3.0.1
        add_tag "v${major}.${minor}"           # v3.0
        add_tag "v${major}"                    # v3
        
    fi

    # Add release type tag
    add_tag "$RELEASE_TYPE"

    # Print tags
    printf '%s\n' "${tags[@]}" | sort -u
}

print_tags() {
    local tags=($(generate_tags))
    echo "The following tags have been generated (Release type: $RELEASE_TYPE):"
    printf '%s\n' "${tags[@]}" | sort

    # Save to GitHub's environment if in CI
    if [[ $CI == "true" && -n "$GITHUB_ENV" ]]; then
        {
            echo "DOCKER_TAGS<<EOF"
            printf '%s\n' "${tags[@]}"
            echo "EOF"
        } >> "$GITHUB_ENV"
    fi
}

help_menu() {
    echo "Usage: $0 [options]"
    echo
    echo "This script generates Docker tags for the SSH image."
    echo
    echo "Optional arguments:"
    echo "  --version <version>      Set the version (e.g., 3.0.1, v3.0.1)"
    echo "  --release-type <type>    Set the release type (e.g., latest, beta, edge). Default: dev"
    echo "  --repository <repos>      Space-separated list of Docker repositories"
}

##################################################
# Main
##################################################

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
        VERSION="$2"
        shift 2
        ;;
        --release-type)
        RELEASE_TYPE="$2"
        shift 2
        ;;
        --repository)
        DOCKER_ORGANIZATIONS="$2"
        shift 2
        ;;
        --help)
        help_menu
        exit 0
        ;;
        *)
        echo "Unknown option: $1"
        help_menu
        exit 1
        ;;
    esac
done

print_tags 