#!/bin/bash
set -eo pipefail

# Simplify directory references
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT_DIR="$SCRIPT_DIR"

# Default values
DOCKER_ORGANIZATIONS="${DOCKER_ORGANIZATIONS:-"docker.io/serversideup ghcr.io/serversideup"}"
DOCKER_REPOSITORY_NAME="${DOCKER_REPOSITORY_NAME:-"docker-ssh"}"
GITHUB_REF_NAME="${GITHUB_REF_NAME:-""}"
PRINT_TAGS_ONLY=false
RELEASE_TYPE="dev"
VERSION=""

# At the top with other variable declarations
declare -a tags=()

##################################################
# Functions
##################################################

add_tag() {
    local new_tag="$1"
    local prefix=""

    # Set prefix based on RELEASE_TYPE
    if [ "$RELEASE_TYPE" != "latest" ] && [ "$RELEASE_TYPE" != "security" ]; then
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
            # Only add PR-specific tags
            tags+=("${org}/${DOCKER_REPOSITORY_NAME}:${full_tag}-${GITHUB_REF_NAME}")
            break
        else
            # Add the regular tag
            tags+=("${org}/${DOCKER_REPOSITORY_NAME}:${full_tag}")
        fi
    done
}

build_image() {
    echo "Building image..."
    
    # Generate tag arguments for docker buildx
    local tag_args=()
    while IFS= read -r tag; do
        tag_args+=("-t" "$tag")
    done < <(generate_tags)
    
    # Build the image with all tags
    docker buildx build \
        -f "$(pwd)/src/Dockerfile" \
        "${tag_args[@]}" \
        .
    
    echo "✅ Image built with tags:"
    generate_tags
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

        # Validate version components
        if [ -z "$major" ] || [ -z "$minor" ] || [ -z "$patch" ]; then
            echo "Error: Invalid version format. Expected format: v1.2.3" >&2
            return 1
        fi

        if [ "$RELEASE_TYPE" = "security" ]; then
            # Only update major and minor version tags for security updates
            add_tag "v${major}"                    # v3
            add_tag "v${major}.${minor}"           # v3.0
        else
            # Add all version tags for regular releases
            add_tag "v${major}.${minor}.${patch}"  # v3.0.1
            add_tag "v${major}.${minor}"           # v3.0
            add_tag "v${major}"                    # v3
        fi
    fi

    # Add release type tag
    if [ "$RELEASE_TYPE" == "latest" ] || [ "$RELEASE_TYPE" == "security" ]; then
        add_tag "latest"
    else
        add_tag "$RELEASE_TYPE"
    fi

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
        --print-tags-only)
        PRINT_TAGS_ONLY=true
        shift
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

if [ "$PRINT_TAGS_ONLY" = false ]; then
    build_image
fi
